package org.dynverse

import ch.systemsx.cisd.hdf5.HDF5Factory
import org.apache.spark.ml.linalg.SparseMatrix
import org.apache.spark.ml.linalg.SparseVector
import org.apache.spark.ml.linalg.DenseVector
import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.feature.PCA
import org.apache.spark.sql.Row
import org.apache.spark.sql.DataFrame

import java.io.File
import java.io.PrintWriter

object Main {
  def main(args: Array[String]) {
    val datasetLocation = args(0)
    val outputFolder = args(1)
    
    // start a spark session
    val spark = SparkSession.
      builder().
      master("local[4]").
      appName("PCAExample").
      getOrCreate()
    
    // import sql context
    import spark.implicits._
    
    // define helper function for writing a data frame to a file
    def dataFrameToCsv(df: DataFrame, file: String) = {
      val header = df.columns.mkString(",") + "\n"
      val body = df.map(_.mkString(",")).select("value").rdd.map(r => r(0)).collect().mkString("\n")
      val text = header + body + "\n"
      val writer = new PrintWriter(file)
      writer.write(text)
      writer.close()
    }
    
    /* ##### Read data ##### */
    // reading the sparse matrix from h5
    val reader = HDF5Factory.openForReading(datasetLocation)

    val dims = reader.readIntArray("data/expression/dims")
    val i = reader.readIntArray("data/expression/i")
    val p = reader.readIntArray("data/expression/p")
    val x = reader.readFloatArray("data/expression/x")
    val cell_ids = reader.readStringArray("data/expression/rownames")

    val mat = new SparseMatrix(dims(0), dims(1), p, i, x.map(_.toDouble)).toSparseRowMajor

    // converting sparse matrix to an array of sparse rows
    val data = mat.colPtrs.sliding(2, 1).map(a => 
      Tuple1(new SparseVector(
        mat.numCols, 
        mat.rowIndices.slice(a(0), a(1)), 
        mat.values.slice(a(0), a(1))
      ))
    ).toArray
    val df = spark.createDataFrame(data).toDF("features")

    /* ##### Infer a trajectory ##### */
    // apply PCA to data
    val pca = new PCA().
      setInputCol("features").
      setOutputCol("pcaFeatures").
      setK(2).
      fit(df)

    // calculate pseudotime
    val result = pca.transform(df).select("pcaFeatures")
    val pt = result.rdd.collect.map{ case Row(x: DenseVector) => x(0) }
    val ptmin = pt.min
    val ptdiff = pt.max - pt.min
    val pseudotime = pt.map(x => (x - ptmin) / ptdiff)

    // creating output data frames
    val milestoneNetwork = Seq(("begin", "end", 1)).toDF("from", "to", "length")

    val progressions =
      (cell_ids zip pseudotime).
        map(a => (a._1, "begin", "end", a._2)).
        toSeq.
        toDF("cell_id", "from", "to", "time")

    /* ##### Save output ##### */
    dataFrameToCsv(milestoneNetwork, s"$outputFolder/milestone_network.csv")
    dataFrameToCsv(progressions, s"$outputFolder/progressions.csv")

    // stop spark
    spark.stop()
  }
}
