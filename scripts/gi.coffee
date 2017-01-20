# Description:
#   Communicates with the API on GhostInspector for WWWINC
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot gi suite list - list available suites
#   hubot gi test list - lists all available tests
#   hubot gi run test <ID> - run a single test with ID = <ID>
#   hubot gi run suite <ID> - run all tests in a suite with ID = <ID>
#
# Author:
#   pbuzzell

api = "8352ccc40f27e325a9e63e25e5d8de9e8ec225c7"
ghostinspector = (msg, query, cb) ->
  msg.http('http://thefuckingweather.com/Where/' + query)
    .header('User-Agent', 'Mozilla/5.0')
    .get() (err, res, body) ->
      
      cb(output)

module.exports = (robot) ->
  robot.respond /gi suite list/i, (msg) ->
    ghostInspector msg, msg.match[2], (output) ->
      result = "Sorry to be a bother.  I'm still learning how to use Ghost Inspector."
      msg.send result
  robot.respond /gi test list/i 