package ro.ciacob.desktop.signals {

	/**
	 * Alternative, simpler approach to the Observer pattern, without the overload of a multiple 
	 * phase event flow, preventing defaults, etc.
	 */
	public interface IObserver {
		/**
		 * Registers a callback to be run when a change of a specific type occurs.
		 * 
		 * THIS IMPLEMENTATION IS NOT INTENDED TO BE USED WHEN MIXING TRUSTED AND UNTRUSTED CODE.
		 * 
		 * @param	changeType:
		 * 			The change to observe. There can be multiple callbacks hooked up to the same
		 * 			change type. CASE INSENSITIVE!
		 * 
		 * @param	callback
		 * 			A callback to run in response to a change of a given type.
		 * 			NOTES:
		 * 			- There can be multiple callbacks hooked up to the same change type.
		 * 			- Re-registering the same callback to the same change type has no effect.
		 * 			- The same callback can be registered to multiple change types. Pass null to the 
		 * 			  `changeType` argument in `stopObserving()` to unregister all of them at once.
		 */
		function observe (changeType : String, callback : Function) : void;
		
		/**
		 * Determines whether this IObserver implementor was set to observe a change of 
		 * a certain type. This should be true if a valid call to "observe(...)" has been
		 * made, with no subsequent call to  "stopObserving(...)" since, both regarding 
		 * the same "changeType".
		 */
		function isObserving (changeType : String) : Boolean;

		/**
		 * Unregisters some previously registered callback(s). 
		 * 
		 * @param	changeType
		 * 			The type of change you are no more interested in observing. Optional, if missing, all
		 * 			change types ever registered are taken into consideration. Case insensitive.
		 * 
		 * @param	callback
		 * 			The specific callback to unregister. Optional, if missing, all callbacks ever registered
		 * 			are taken into consideration.
		 *   
		 * NOTES:
		 * 1. The same callback can be registered to multiple change types. Pass null to the 
		 *   `changeType` argument in `stopObserving()` to unregister all of them at once.
		 * 2. Although this method signature is permissive (all parameters are optional), only a few combinations
		 *    make sense and will work:
		 * 
		 *   a) only `changeType` set will unregister all callbacks registered in that change type;
		 * 
		 *   b) `changeType` set and `callback` set will unregister matching callback(s) registered in that change type;
		 * 
		 * 	 c) `changeType` omitted and the `callback` set will unregister matching callbacks regardless of the change
		 *   type they were registered with;
		 * 
		 *   d) no parameter set will loop through all callbacks in the stack, and will unregister them all.
		 *      USE WITH EXTREMELY CARE, AND ONLY FOR PERMITTING GARBAGE COLLECTION OF AN OBJECT THAT IS ABOUT
		 *      TO BE DISPOSED.
		 */
		function stopObserving (changeType : String = null, callback : Function = null) : void;
		
		/**
		 * Executes all the callbacks registered to a specific change type, in the order of their registration. 
		 * 
		 * NOTE:
		 * Re-registering an unregistered callback does not preserve its previous order, instead adds it to the
		 * last position. The order callbacks are executed in should not be relied upon, anyway.
		 * 
		 * @param	changeType
		 * 			The type of change that is (supposedly) happening. Case insensitive.
		 * 
		 * @param	details
		 * 			Any parameters you want to send to the callback, in any order, and of any type.
		 */
		function notifyChange (changeType : String, ... details) : void;
	}
}
