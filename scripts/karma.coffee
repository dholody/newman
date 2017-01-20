# Description:
#   Track arbitrary points
#
# Dependencies:
#   None
#
# Configuration:
#   points_ALLOW_SELF
#
# Commands:
#   <thing>++ - give thing some points
#   <thing>-- - take away some of thing's points
#   hubot points <thing> - check thing's points (if <thing> is omitted, show the top 5)
#   hubot points empty <thing> - empty a thing's points
#   hubot points best - show the top 5
#   hubot points worst - show the bottom 5
#
# Author:
#   stuartf
#
class points

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = [
      "+1!", "gained a level!", "is on the rise!", "leveled up!", "is heating up!"
    ]

    @decrement_responses = [
      "took a hit! Ouch.", "took a dive.", "lost a life.", "lost a point.", "screwed the pooch."
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.points
        @cache = @robot.brain.data.points

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.points = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.points = @cache

  decrement: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.points = @cache

  incrementResponse: ->
     @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  decrementResponse: ->
     @decrement_responses[Math.floor(Math.random() * @decrement_responses.length)]

  selfDeniedResponses: (name) ->
    @self_denied_responses = [
      "Hey everyone! #{name} is a narcissist!",
      "I might just allow that next time, but no.",
      "I can't do that #{name}."
    ]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, points: val })
    s.sort (a, b) -> b.points - a.points

  top: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) ->
    sorted = @sort()
    sorted.slice(-n).reverse()

module.exports = (robot) ->
  points = new points robot
  allow_self = process.env.points_ALLOW_SELF or "true"

  robot.hear /^(\S+[^+:\s])[: ]*(\+\+|ftw!*)\s*($)/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    if allow_self is true or msg.message.user.name.toLowerCase() != subject
      points.increment subject
      msg.send "#{subject} #{points.incrementResponse()} (Score: #{points.get(subject)})"
    else
      msg.send msg.random points.selfDeniedResponses(msg.message.user.name)

  robot.hear /^(\S+[^-:\s])[: ]*(--|fail!*)\s*($)/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    if allow_self is true or msg.message.user.name.toLowerCase() != subject
      points.decrement subject
      msg.send "#{subject} #{points.decrementResponse()} (Score: #{points.get(subject)})"
    else
      msg.send msg.random points.selfDeniedResponses(msg.message.user.name)

  robot.respond /points empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    if allow_self is true or msg.message.user.name.toLowerCase() != subject
      points.kill subject
      msg.send "#{subject} has had its points scattered to the winds."
    else
      msg.send msg.random points.selfDeniedResponses(msg.message.user.name)

  robot.respond /points( best)?$/i, (msg) ->
    verbiage = ["The Most"]
    for item, rank in points.top()
      verbiage.push "#{rank + 1}. #{item.name} - #{item.points}"
    msg.send verbiage.join("\n")

  robot.respond /points worst$/i, (msg) ->
    verbiage = ["The Least"]
    for item, rank in points.bottom()
      verbiage.push "#{rank + 1}. #{item.name} - #{item.points}"
    msg.send verbiage.join("\n")

  robot.respond /points (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if match != "most" && match != "least"
      msg.send "\"#{match}\" has #{points.get(match)} points."