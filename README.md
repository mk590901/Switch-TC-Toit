# Switch-TC-Toit

The application tests threaded code generated by the editor of hierarchical state machines. The original scheme can be seen on the __switch_reset.svg__ attached to the project. It's model of a switch affected by two events: __TURN__ and __RESET__. The first switches two states __ON__ and __OFF__, the second resets the state machine to the __OFF__ state regardless of what state it was in before.

## Precondition

The editor's __Planner__ module was supplemented with __toit__ code generator, which automatically create the __switch_reset_helper.toit__ file with __Switch_resetHelper__ and __Switch_resetComposer__ classes inside. Unlike previously used programming languages, class __Switch_resetHelper__ does not contain transfer functions, because Toit doesn't have the ability to statically initialize vectors containing class functions (methods). Therefore, class __Switch_resetComposer__ was created in which vectors of __λ-functions__ are created dynamically on demand via the __compose__ method.. Class __Switch_resetHelper__ contains function __createHelper__ builds __QHsmHelper__ class for processing these functions. A core has also been added to the application, which services the launch of threaded code and the impact of events on it. This is a set of several very simple classes placed to the __tc_core.toit__ file: __EventWrapper__, which describes and keep an event, __QHsmHelper__ which contains a container of threaded codes and ensures its execution under the influence of events, __ThreadedCodeExecutor__ - a class ensures the launch of threaded code for a specific state and event.

The generated __switch_reset_helper.toit__ file is a skeleton for the logical part of the application, namely the list and bodies of empty transfer functions that can and should be filled with some content. For example, with trace elements in the simplest case. Some functions may not be used and should be deleted or commented out:

>switch_reset_helper.toit

```toit

import .tc_core show *

//////////////////////////////////////////////////
//  class Switch_resetHelper
//////////////////////////////////////////////////    
class Switch_resetHelper :

  composer_/Switch_resetComposer := Switch_resetComposer
  helper_/QHsmHelper := QHsmHelper "switch"

  constructor :
    create_helper

  create_helper -> none :
    helper_.insert "switch" "init"  (ThreadedCodeExecutor helper_ "off" (composer_.compose "switch.init"))
    helper_.insert "off"    "RESET" (ThreadedCodeExecutor helper_ "off" (composer_.compose "off.RESET"))
    helper_.insert "off"    "TURN"  (ThreadedCodeExecutor helper_ "on"  (composer_.compose "off.TURN"))
    helper_.insert "on"     "RESET" (ThreadedCodeExecutor helper_ "off" (composer_.compose "on.RESET"))
    helper_.insert "on"     "TURN"  (ThreadedCodeExecutor helper_ "off" (composer_.compose "on.TURN"))

  init -> none :
    helper_.post "init" 1

  run eventName/string -> none :
    helper_.post eventName 2

  state -> string :
    return helper_.get_state
    
//////////////////////////////////////////////////
//  class Switch_resetComposer
//////////////////////////////////////////////////          
class Switch_resetComposer : 

  off_entry data/any -> none :
    print "OFF"

  off_reset data/any -> none :
    print "@RESET"

  off_turn data/any -> none :
    print "OFF: TURN"

  on_entry data/any -> none :
    print "ON"

  on_turn data/any -> none :
    print "ON : TURN"

  compose key/string -> List :
    list/List := []
    
    if key == "off.RESET" :
      list.add :: | p | off_reset p
      list.add :: | p | off_entry p
      //print "compose off.RESET [$list.size]"
      return list

    if key == "off.TURN" :
      list.add :: | p | off_turn p
      list.add :: | p | on_entry p
      //print "compose off.TURN [$list.size]"
      return list

    if key == "on.TURN" :
      list.add :: | p | on_turn p
      list.add :: | p | off_entry p
      //print "compose on.TURN [$list.size]"
      return list

    if key == "switch.init" :
      list.add :: | p | off_entry p
      //print "compose switch.init [$list.size]"
      return list;

    if key == "on.RESET" :
      list.add :: | p | off_reset p
      list.add :: | p | off_entry p
      //print "compose on.RESET [$list.size]"
      return list
  
    return list;

```

## Additional modules

To test the threaded code for hierarchical state machine, need to manually create small module that ensure the launch of the application:

>test_switch.toit

```toit

import .tc_core show *
import .switch_reset_helper show *
main :

  switchHelper/Switch_resetHelper := Switch_resetHelper
  switchHelper.init
  switchHelper.run "TURN"
  switchHelper.run "RESET"
  switchHelper.run "TURN"
  switchHelper.run "TURN"
  switchHelper.run "RESET"

```

## Description of the application

There are several methods can use to run the application:

>Launch as a console application, using the __toit execute__ command:

```

michael-k@michaelk-Inspiron-14-5420:~/toit_apps/threaded_code$ toit execute switch_test.toit
OFF
OFF: TURN
ON
@RESET
OFF
OFF: TURN
ON
ON : TURN
OFF
@RESET
OFF
michael-k@michaelk-Inspiron-14-5420:~/toit_apps/threaded_code$

```

>On an ESP32 chip named mini, using __toit run__ command:

![PXL_20250110_102511520 PORTRAIT](https://github.com/user-attachments/assets/e3b7cd0f-675c-4948-85c0-721c1ff7a681)

```

michael-k@michaelk-Inspiron-14-5420:~/toit_apps/threaded_code$ toit run -d=mini switch_test.toit
2025-01-09T12:40:24.418020Z: <process initiated>
OFF
OFF: TURN
ON
@RESET
OFF
OFF: TURN
ON
ON : TURN
OFF
@RESET
OFF
2025-01-09T12:40:24.893627Z: <process terminated - exit code: 0>
michael-k@michaelk-Inspiron-14-5420:~/toit_apps/threaded_code$

```

>On an advanced ESP32-S3 chip, using __Jaguar__ command:

![PXL_20250109_123242772 MP](https://github.com/user-attachments/assets/c8e510a3-3915-4d44-947a-7e132802dd2d)


```
micrcx@micrcx-desktop:~/toit/threaded_code$ jag run switch_test.toit
Running 'switch_test.toit' on 'reversed-area' ...
Success: Sent 37KB code to 'reversed-area'
micrcx@micrcx-desktop:~/toit/threaded_code$

```

>Trace on monitor

```
[jaguar] INFO: program 962d55d5-99fe-8425-a7a7-791a4892b2bd started
OFF
OFF: TURN
ON
@RESET
OFF
OFF: TURN
ON
ON : TURN
OFF
@RESET
OFF
[jaguar] INFO: program 962d55d5-99fe-8425-a7a7-791a4892b2bd stopped

```

# Movie

[merge.webm](https://github.com/user-attachments/assets/2e4db4c7-54d4-4ea7-9246-536a84e49848)






