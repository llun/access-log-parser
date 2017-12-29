const _ = require('lodash')
const elasticsearch = require('elasticsearch')

const client = new elasticsearch.Client({
  host: 'localhost:9200'
})

let batch = []

module.exports = {
  save: function(body) {
    batch.push(body)
    if (batch.length === 50) {
      return new Promise((resolve, reject) => {
        const localBatch = _.flatten(
          batch.map(item => [
            {
              index: {
                _index: 'access',
                _type: 'log'
              }
            },
            item
          ])
        )
        batch = []
        client.bulk(
          {
            body: localBatch
          },
          (error, response) => {
            if (error) return reject(error)
            resolve(response)
          }
        )
      })
    }
  }
}
