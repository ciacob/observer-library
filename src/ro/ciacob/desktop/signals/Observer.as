package ro.ciacob.desktop.signals {
	import ro.ciacob.utils.Objects;

	/**
	 * Reference implementation for the IObserver interface.
	 *
	 * This class is meant to be composed into IObserver implementors rather than
	 * subclassed, ideally by employing the Decorator pattern.
	 */
	public final class Observer implements IObserver {
		private static const CALLBACK:String = 'callback';
		private static const INDEX:String = 'index';
		private static const OWNER:String = 'owner';

		public function Observer() {
			_subscribers = {};
		}

		private var _subscribers:Object;

		public function isObserving(changeType:String):Boolean {
			if (changeType != null) {
				var key : String = changeType.toLocaleLowerCase();
				return (key in _subscribers);
			}
			return false;
		}

		public function notifyChange(changeType:String, ... details):void {
			changeType = changeType.toLowerCase();
			if (changeType in _subscribers) {
				var specificSubscribers:Array = (_subscribers[changeType] as Array);
				if (specificSubscribers != null) {
					var i:int;
					var entry:Object;
					var callback:Function;
					for (i = 0; i < specificSubscribers.length; i++) {
						entry = (_subscribers[changeType] as Array)[i];
						callback = entry[CALLBACK];
						callback.apply (null, details);
					}
				}
			}
		}

		public final function observe(changeType:String, callback:Function) : void {
			changeType = changeType.toLowerCase();
			if (!(changeType in _subscribers)) {
				_subscribers[changeType] = [];
			}
			var existingCallbackIndex : int = (_searchCallback (callback, changeType))[INDEX];
			var callbackExists:Boolean = (existingCallbackIndex >= 0);
			// Re-registering the same callback to the same type has no effect.
			if (callbackExists) {
				return;
			}
			var newEntry : Object = {};
			newEntry[CALLBACK] = callback;
			(_subscribers[changeType] as Array).push (newEntry);
		}

		public final function stopObserving (changeType : String = null, callback : Function = null) : void {
			
			// Unregister everything
			if (changeType == null && callback == null) {
				_disposeStackEntirely();
				return;
			}

			// Unregister a specific callback from one or all change types
			if (changeType != null) {
				changeType = changeType.toLowerCase();
			}
			if (callback != null) {
				do {
					var searchResults : Object = _searchCallback (callback, changeType);
					var foundIndex : int = searchResults[INDEX];
					var foundOwner : String = searchResults[OWNER];
					var callbackExists : Boolean = (foundIndex >= 0);
					if (callbackExists) {
						(_subscribers[foundOwner] as Array).splice (foundIndex, 1);
					} else {
						break;
					}
				} while (true);
			}
			
			// Unregister all callbacks from a specific change type
			else {
				if (changeType != null) {
					delete _subscribers[changeType];
				}
			}
		}

		private function _disposeStackEntirely():void {
			var deletionList:Array = [];
			for (var changeType:String in _subscribers) {
				for (var i:int = 0; i < (_subscribers[changeType] as Array).length; i++) {
					var entry:Object = (_subscribers[changeType] as Array)[i];
					var callback:Function = entry[CALLBACK];
					if (deletionList.indexOf(callback) == -1) {
						deletionList.push(callback);
					}
				}
			}
			while (deletionList.length > 0) {
				var callbackToDelete:Function = deletionList.shift();
				stopObserving(null, callbackToDelete);
			}
		}

		private function _searchCallback(callback:Function, changeType:String) : Object {
			var callbackOwner:String = null;
			var callbackIndex:int = -1;
			var types:Array = (changeType != null) ? [changeType] : Objects.getKeys(_subscribers);
			outerLoop: for (var j:int = 0; j < types.length; j++) {
				var currentChangeType:String = types[j];
				var matchingSubscribers:Array = (_subscribers[currentChangeType] as Array);
				if (matchingSubscribers != null) {
					for (var i:int = 0; i < matchingSubscribers.length; i++) {
						var entry:Object = (_subscribers[currentChangeType] as Array)[i];
						if (entry[CALLBACK] === callback) {
							callbackOwner = currentChangeType;
							callbackIndex = i;
							break outerLoop;
						}
					}
				}
			}
			var ret:Object = {};
			ret[OWNER] = callbackOwner;
			ret[INDEX] = callbackIndex;
			return ret;
		}
	}
}
