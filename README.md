delayed_resque
==============

Provides [delayed_job](https://github.com/collectiveidea/delayed_job) syntax to [resque](https://github.com/resque/resque).

  [![Code Climate](https://codeclimate.com/github/meetme2meat/delayed_resque.png)](https://codeclimate.com/github/meetme2meat/delayed_resque)

### DelayedJob syntax supported are 
1 . `delay`

Call `.delay.method(params)` on any object and it will be processed in the background.

    # with delay
    @user.delay.activate!(@device)

Parameters can be scalar values, active record instances, or classes (but not instances of non-AR objects).

The queue to use for the method can be specified on the delay method:

    @user.delay(:queue => :device_activation).activate!(@device)

2 . `delay` + `unqiue`
    
```
# with delay and unique
@user.delay(:unique => true).activate!(@device)
```

3 . `delay` + `run_at` 

``` 
# with delay and run_at
@user.delay(:run_at => 10.second.from_now).activate!(@device)   
```
Ideally this accomplice in conjunction with [resque-scheduler](https://github.com/bvandenbos/resque-scheduler) so make sure to start resque-scheduler for this for more on how the resque-scheduler work check the [Readme](https://github.com/bvandenbos/resque-scheduler/blob/master/README.markdown) 

4 . `handle_asynchronously` 
 Out of the box support for `handle_asynchronously` method supported over `delayed_job`  
 

Caveats
---------- 
All the gem is attempt to touch the all aspect of `delayed_job` to `resque` but there are some which cannot be achieved currently one of them is `priority` and reason for that is `resque` does not have currently a robust priority mechanism like `delayed_job` 
 
Credits
-------

Based on the work of https://github.com/defunkt/resque and 
https://github.com/collectiveidea/delayed_job.

Special Thanks to https://github.com/k1w1 for extracting most of the code out of delayed_job