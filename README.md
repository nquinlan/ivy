## Ivy [![Build Status](https://travis-ci.org/apiaryio/ivy.png?branch=master)](https://travis-ci.org/apiaryio/ivy)

[Ivy](https://github.com/apiaryio/ivy) is [node.js](http://nodejs.org) queue library focused on easy, yet flexible task execution.

### Problem solved by Ivy

Ivy touches the following workflow:

* Function execution is scheduled from application ("producer") in similar way as executing function directly
* Call is serialized and transferred through queue to worker. Producer subscribes to notifier for completion
  * Worker job is considered essential. It should be thus delivered through robust, HA queue, such as AMQP, RabbitMQ, SQS, IronMQ or similar.
  * Arguments are send as a stringifyed JSON. There is no attempt to magically recover original object; called functions should thus rely only on attribute access, not method calls
* Worker executes function on shared code base, with arguments fetched from queue task
  * If execution errors, task stays in MQ or is returned there, depending on implementation
  * If it fails permanently, please beware of JSON.stringify(new Error()) idiosyncrasy
* Producer is notified back about completion
  * Speed over robustness is preferred as this should be about notifying client back, not further work
  * Thus, redis pub/sub is preferred
  * If non-notification work should follow after execution is done, it should be scheduled as another task in MQ

Thoughts:

* Only tasks/functions with async interface supported. Assumptions:
  * callback is last argument provided
  * callback must be present
  * first argument of callback signature is either Error or null

### Installation

Installation is done via NPM, by running ```npm install ivy```

### Features

* Super easy to use


### Quick example

```javascript

var ivy = require('ivy');

var factorial = function factorial(number, callback) {
    callback(null, 42);
}

var finished  = function resolved(result) {
    console.log('result is', result);
}


// task must be explicitly registered for now
// we'd like to change that in the future

// Also, task must be both available and registered on both client
// and producer

// ...and name must be unique globally. "package.module.submodule.function"
// pattern is highly encouraged.
ivy.registerTask(factorial, {
   'name':   'testpackage.factorial',
   'queue':  'testpackage' //,
//    'route':  'testpackage.route1',
//    'priority': 0,
//    retry:    true,
//    maxRetries: 10
});

if (process.env.NODE_ENV==='producer') {
  // schedule task execution
  ivy.delayedCall(factorial, 5, function(err, result) {
    console.log("Factorial result is", result);
  };

  // or, execute task, but wait it was scheduled properly
  ivy.confirmedDelayedCall(factorial, 5, function(err, result) {
    console.log("Factorial result is", result);
  }, function (err, taskId) {
    if (err) {
      console.error("Task wasn't scheduled! Error was: ", err);
    }
    else {
      console.log("Task scheduled. Waiting for notitication ID", taskId);
    }
  });

}
elseif (process.env.NODE_ENV==='worker') {
    ivy.listen({
        queue: 'testpackage',

        type: 'ironmq',
        auth: {
            token: process.env.IRONMQ_TOKEN || 'dummy',
            project_id: process.env.IRONMQ_PROJECT or 'testpackage'
        },

        // optional
        messages: {
            'testpackage.factorial': {
                reserveTime: 60*60
            }
        }

    });

}

ivy.notifier({
    'type': 'redis',
    'url':  'redis://name:password@hostname:port'
});
```
