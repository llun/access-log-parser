const _ = require('lodash')
const fs = require('fs')
const path = require('path')
const through2 = require('through2')

const parser = require('./parser')
const store = require('./store')

const ROOT_LOGS_DIR = 'logs'

try {
  fs.accessSync(
    path.join(__dirname, ROOT_LOGS_DIR),
    fs.constants.R_OK | fs.constants.X_OK
  )
} catch (e) {
  console.error('Cannot read logs directory')
  process.exit(-1)
  return
}

const dirs = fs
  .readdirSync(path.join(__dirname, ROOT_LOGS_DIR))
  .filter(item =>
    fs.statSync(path.join(__dirname, ROOT_LOGS_DIR, item)).isDirectory()
  )
const logs = _.flatten(
  dirs.map(logDir =>
    fs
      .readdirSync(path.join(__dirname, ROOT_LOGS_DIR, logDir))
      .map(item => path.join(__dirname, ROOT_LOGS_DIR, logDir, item))
  )
)
async function process(logs) {
  for (let log of logs) {
    await new Promise(resolve => {
      console.log(log)
      parser(log)
        .pipe(
          through2(function(line, enc, callback) {
            const data = JSON.parse(line.toString())
            store.save(data)
            callback()
          })
        )
        .on('error', e => {
          console.error('error', e)
        })
        .on('finish', () => {
          resolve()
        })
    })
  }
}

process(logs)
  .then(() => console.log('done'))
  .catch(error => console.error(error))
