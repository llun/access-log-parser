const fs = require('fs')
const path = require('path')

const RECORD_NAME_LENGTH = 10
const MAX_RECORDS_PER_FILE = 100000
const ROOT_OUT_DIR = 'results'

try {
  fs.accessSync(
    path.join(__dirname, ROOT_OUT_DIR),
    fs.constants.R_OK | fs.constants.X_OK
  )
} catch (e) {
  console.error('Cannot read output directory')
  process.exit(-1)
  return
}

let currentIndex = 0
let buffer = []
module.exports = {
  save: function(data) {
    buffer.push(data)
    if (buffer.length === MAX_RECORDS_PER_FILE) {
      const filename = `${currentIndex}`.padStart(RECORD_NAME_LENGTH, '0')
      console.log(
        'write file to',
        path.join(__dirname, ROOT_OUT_DIR, `${filename}.json`)
      )
      fs.writeFileSync(
        path.join(__dirname, ROOT_OUT_DIR, `${filename}.json`),
        JSON.stringify(buffer)
      )
      currentIndex++
      buffer = []
    }
  }
}
