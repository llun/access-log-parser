const peg = require('pegjs')
const _ = require('lodash')
const fs = require('fs')
const through2 = require('through2')

const grammar = fs.readFileSync('./syntax.pegjs', { encoding: 'utf8' })
const parser = peg.generate(grammar)

const dirs = fs
  .readdirSync(__dirname)
  .filter(item => /^i-\w+$/.test(item) && fs.statSync(item).isDirectory())
const logs = _.flatten(
  dirs.map(logDir =>
    fs
      .readdirSync(`${__dirname}/${logDir}`)
      .map(item => `${__dirname}/${logDir}/${item}`)
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
