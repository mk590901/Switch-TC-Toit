import monitor

//////////////////////////////////////////////////
//  class Queue
//////////////////////////////////////////////////
class Queue :
  _locker ::= monitor.Mutex
  _queue := []
  
  isEmpty :
    rc := false
    _locker.do :
      if (_queue.size == 0) :
        rc = true
    return rc
  
  put message :
    _locker.do :
      _queue.add message
    
  get :
    out := null
    _locker.do :
      if _queue.size > 0 :
        out = _queue[0]
        _queue.remove out
    return out 
    
  trace prompt :
    print ("$prompt$_queue")

//////////////////////////////////////////////////
//  Function create_key
//////////////////////////////////////////////////
create_key s/string t/string -> string :
  return "$s.$t"

//////////////////////////////////////////////////
//  class IQHsmStateMachineHelper
//////////////////////////////////////////////////
abstract class IQHsmStateMachineHelper :
  abstract get_state -> string
  abstract set_state state/string -> none
  abstract executor event/string -> ThreadedCodeExecutor?

//////////////////////////////////////////////////
//  class EventWrapper
//////////////////////////////////////////////////
class EventWrapper :
  _data/Object?
  _event/string
  
  constructor event/string data/Object? :
    _event = event
    _data = data
  
  data -> Object? :
    return _data
  
  event -> string :
    return _event

//////////////////////////////////////////////////
//  class Runner
//////////////////////////////////////////////////
class Runner:
  _events_queue := Queue //[] //List EventWrapper
  _helper/IQHsmStateMachineHelper? := null
    
  constructor helper/IQHsmStateMachineHelper? :
    _helper = helper

  post event/string data/Object? -> none :    
    _events_queue.put (EventWrapper event data)
    while (not _events_queue.isEmpty) :
      event_wrapper/EventWrapper := _events_queue.get
      tc_executor := _helper.executor event_wrapper.event
      if (tc_executor == null) :
        print "post: failed to get executor($event)"
        return
      tc_executor.executeSync data

//////////////////////////////////////////////////
//  class QHsmHelper
//////////////////////////////////////////////////
class QHsmHelper extends IQHsmStateMachineHelper :
  _state/string := ""
  _runner/Runner? := null
  _container/Map := {:}

  constructor state/string :
    _state = state
    _runner = Runner this
 
  get_state -> string :
    return _state
  
  set_state state/string -> none :
    _state = state
  
  executor event/string -> ThreadedCodeExecutor? :
    key/string := create_key _state event
    if not _container.contains key :
      print "runSync.error: $_state->$event"
      return null
    tc_executor := _container[key]
    return tc_executor
  
  insert state/string event/string tc_executor/ThreadedCodeExecutor :
    key/string := create_key state event
    _container[key] = tc_executor 

  post event/string data/any -> none :    
    _runner.post event data
  
//////////////////////////////////////////////////
//  class ThreadedCodeExecutor
//////////////////////////////////////////////////
class ThreadedCodeExecutor :
  target_state_/string := ""
  helper_/IQHsmStateMachineHelper? := null
  container_/List := []
    
  constructor helper/IQHsmStateMachineHelper? target_state/string container/List :
    target_state_ = target_state
    helper_ = helper
    container_ = container
    
  executeSync data/any -> none :
    helper_.set_state target_state_
    container_.do : | fun/Lambda |
      fun.call data

