#
#    Copyright 2016 The Symphony Software Foundation
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

assert = require('chai').assert
SymphonyAdapter = require '../src/adapter'
NockServer = require './nock-server'
{FakeRobot} = require './fakes'

nock = new NockServer('https://foundation-bot.symphony.com')

process.env['HUBOT_SYMPHONY_HOST'] = 'foundation-bot.symphony.com'
process.env['HUBOT_SYMPHONY_PUBLIC_KEY'] = './test/resources/publicKey.pem'
process.env['HUBOT_SYMPHONY_PRIVATE_KEY'] = './test/resources/privateKey.pem'
process.env['HUBOT_SYMPHONY_PASSPHRASE'] = 'changeit'

describe 'Adapter test suite', () ->
  constructorProps = ['HUBOT_SYMPHONY_HOST', 'HUBOT_SYMPHONY_PUBLIC_KEY', 'HUBOT_SYMPHONY_PRIVATE_KEY', 'HUBOT_SYMPHONY_PASSPHRASE']

  for constructorProp in constructorProps
    it "should throw on construction if #{constructorProp} missing", () ->
      prop = process.env[constructorProp]
      delete process.env[constructorProp]
      assert.throws(SymphonyAdapter.use, new RegExp("#{constructorProp} undefined"))
      process.env[constructorProp] = prop

  it 'should connect and receive message', (done) ->
    robot = new FakeRobot
    adapter = SymphonyAdapter.use(robot)
    adapter.on 'connected', () ->
      assert.isDefined(adapter.symphony)
      robot.on 'received', () ->
        assert.isAtLeast((m for m in robot.received when m.text is 'Hello World').length, 1)
        adapter.close()
        done()
    adapter.run()
