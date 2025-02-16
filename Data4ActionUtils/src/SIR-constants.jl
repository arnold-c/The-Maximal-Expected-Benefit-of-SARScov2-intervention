const N = 673
const classLsize = 106
const classMsize = 311
const classHsize = 256
const classLprop = classLsize / N
const classMprop = classMsize / N
const classHprop = classHsize / N

const beta_LL = 1.0

const classLpositive = 40
const classMpositive = 100
const classHpositive = 65

const classLseroprev = round(classLpositive / classLsize; digits = 4)
const classMseroprev = round(classMpositive / classMsize; digits = 4)
const classHseroprev = round(classHpositive / classHsize; digits = 4)

const obs_final_Cs = [
    classLseroprev * classLprop,
    classMseroprev * classMprop,
    classHseroprev * classHprop,
]
