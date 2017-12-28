const _ = require('lodash')
const peg = require('pegjs')
const fs = require('fs')
const path = require('path')
const through2 = require('through2')

const ROOT_LOGS_DIR = 'logs'

const grammar = fs.readFileSync('./syntax.pegjs', { encoding: 'utf8' })
const parser = peg.generate(grammar)

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
logs.forEach(item => {
  fs
    .createReadStream(item, { autoClose: true })
    .pipe(
      // Convert chunk into line
      through2(function(chunk, enc, callback) {
        const lines = chunk.toString().split('\n')
        const lastLine = lines[lines.length - 1]
        if (this._previous) {
          lines[0] = [this._previous, lines[0]].join('')
          this._previous = ''
        }
        if (lastLine) this._previous = lines.pop()
        lines.forEach((line, index) => {
          this.push(line)
        })
        callback()
      })
    )
    .pipe(
      through2((line, enc, callback) => {
        const decodedLine = line.toString()
        try {
          console.log(parser.parse(decodedLine))
        } catch (error) {
          console.log(decodedLine)
          console.log(parser.parse(decodedLine))
          throw error
        }
        callback()
      })
    )
})
