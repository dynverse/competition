#!/usr/bin/env node

// load data
const fs = require('fs');
const util = require('util');

const testCases = fs.readdirSync('ground-truths');

console.log(util.inspect(testCases));

const difficulties = JSON.parse(fs.readFileSync('difficulties.json'));

// define functions for normalization
function normalcdf(x, mean, sigma)
{
    var z = (x-mean)/Math.sqrt(2*sigma*sigma);
    var t = 1/(1+0.3275911*Math.abs(z));
    var a1 =  0.254829592;
    var a2 = -0.284496736;
    var a3 =  1.421413741;
    var a4 = -1.453152027;
    var a5 =  1.061405429;
    var erf = 1-(((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*Math.exp(-z*z);
    var sign = 1;
    if(z < 0)
    {
        sign = -1;
    }
    return (1/2)*(1+sign*erf);
}

function normalise_score(score, mean, sd) {
   normalcdf(score, mean, sd)
}

// calculate the score

let score = 0;

const solutionTime = process.argv[2];

testCases.forEach((testCase) => {
  let name = testCase.split('/');
  name = name[name.length - 1].replace(/\.h5$/, '');
  if (fs.existsSync(`outputs/${name}`)) {
    const scores = JSON.parse(fs.readFileSync(`outputs/${name}/scores.json`))[0];
    score += Math.pow((
      normalise_score(scores.F1_branches, difficulties.F1_branches.mean[name], difficulties.F1_branches.sd[name]) *
      normalise_score(scores.correlation, difficulties.correlation.mean[name], difficulties.correlation.sd[name]) *
      normalise_score(scores.featureimp_wcor, difficulties.featureimp_wcor.mean[name], difficulties.featureimp_wcor.sd[name]) *
      normalise_score(scores.him, difficulties.him.mean[name], difficulties.him.sd[name])
    ), 1/4);
    console.log(score);
  }
});

score /= testCases.length;

if (solutionTime) {
  score *= Math.exp(- Number(solutionTime) / testCases.length / 60000);
}

fs.writeFileSync('outputs/AGGREGATED_SCORE', score);
