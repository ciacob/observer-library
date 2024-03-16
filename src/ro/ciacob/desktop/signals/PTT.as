package ro.ciacob.desktop.signals {


	/**
	 * The PTT (Pneumatic Tube Transport) class provides a synchronous inter-object communication system
	 * for AS3 applications. It provides an alternative to the AS3 bubbling event model: a simpler,
	 * synchronous and more straightforward way of passing information between objects, while keeping
	 * them decoupled.
	 *
	 * PTT supports the use of pipes to isolate and direct information flow to specific subscribers. It
	 * also allows for retroactive subscription, where late subscribers can receive the last content
	 * sent to a specific address.
	 *
	 * Examples:
	 * <code>
	 *      // Sending out information
	 *      PTT.getPipe(pipeName).send(address, content);
	 *
	 *      // Subscribing to receive content
	 *      PTT.getPipe(pipeName).subscribe(address, handler);
	 *
	 *      // Unsubscribing from receiving content
	 *      PTT.getPipe(pipeName).unsubscribe(address, handler);
	 *
	 *      // Retroactively subscribing to receive last content
	 *      PTT.getPipe(pipeName).retroactivelySubscribe(address, callback);
	 *
	 *      // Checking for and accessing backup of last delivery
	 *      if (PTT.getPipe(pipeName).hasBackupFor(address)) {
	 *          PTT.getPipe(pipeName).recoverBackupFor(address);
	 *      }
	 *
	 *      // Discarding backups of last delivery
	 *      if (PTT.getPipe(pipeName).hasBackupFor(address)) {
	 *          PTT.getPipe(pipeName).deleteBackupFor(address);
	 *      }
	 *
	 *      // Preparing for garbage collection
	 *      PTT.getPipe(pipeName).trash();
	 * </code>
	 *
	 * @author ciacob
	 */
	public class PTT {

		public static const PUBLIC_PIPE : String = 'publicPipe';

		private static var _pipes : Object = {};
		private static var _requestedPipe : String;
		
		private var _backups : Object;
		private var _observer : IObserver;

		/**
		 * Retrieves a PTT instance for transmitting content. If omitted, defaults to the
		 * default (public) instance. Note that there is no publicly accessible list of pipe
		 * instances.
		 *
		 * @param id The name of a pipe. Accepted values are Strings, numbers, or any instance
		 * containing a `toString()` member function. `Null` is assumed for non-accepted
		 * values.
		 *
		 * @return A discreet PTT instance corresponding to the given pipe name.
		 */
		public static function getPipe (id : String = null) : PTT {
			var pipeName : String = id || PUBLIC_PIPE;
			_requestedPipe = pipeName;
			if (!(_requestedPipe in _pipes)) {
				_pipes[_requestedPipe] = new PTT;
			}
			var pipe : PTT = (_pipes[_requestedPipe] as PTT);
			_requestedPipe = null;
			return pipe;
		}

		/**
		 * Initializes a new instance of the PTT class.
		 * @constructor
		 */
		public function PTT () {
			if (_requestedPipe == null || _pipes[_requestedPipe] != null) {
				throw (new Error ('The PTT class cannot be initialized directly. Use `PTT.getPipe("myPipe")` instead.'));
			}
			_observer = new Observer;
			_backups = {};
		}

		/**
		 * Deletes the backup content for a given address.
		 *
		 * @param address The address for which to delete the backup content.
		 */
		public function deleteBackupFor (address : String) : void {
			if (hasBackupFor (address)) {
				delete _backups[address];
			}
		}

		/**
		 * Checks if there is backup content available for a given address.
		 *
		 * @param address The address for which to check backup content availability.
		 *
		 * @return True if there is backup content available, otherwise false.
		 */
		public function hasBackupFor (address : String) : Boolean {
			return (address in _backups);
		}

		/**
		 * Retrieves the backup content for a given address, if available.
		 *
		 * @param address The address for which to retrieve the backup content.
		 *
		 * @return The backup content if available, otherwise null.
		 */
		public function recoverBackupFor (address : String) : Object {
			if (hasBackupFor (address)) {
				return _backups[address];
			}
			return null;
		}

		/**
		 * Sends content to the specified address within the pipe.
		 *
		 * @param address The address to which the content will be sent.
		 * @param content The content to send.
		 */
		public function send (address : String, content : Object = null) : void {
			if (_hasSubscribers (address)) {
				_observer.notifyChange (address, content);
			} else {
				_backups[address] = content;
			}
		}

		/**
		 * Subscribes a callback function to receive content updates for a specific address within
		 * the pipe.
		 *
		 * @param address The address for which to subscribe to receive content updates.
		 * @param handler The callback function to be invoked when content is sent to the specified address.
		 *
		 * @throws ArgumentError If the handler function is missing.
		 */
		public function subscribe (address : String, handler : Function) : void {
			if (handler == null) {
				throw(new ArgumentError ('PTT.subscribe: argument `handler` cannot be missing.'));
			}
			_observer.observe (address, handler);
		}

		/**
		 * Subscribes a callback function to receive content updates for a specific address within
		 * the pipe and immediately delivers the last content if available.
		 *
		 * @param address The address for which to subscribe to receive content updates.
		 * @param callback The callback function to be invoked when content is sent to the specified address.
		 */
		public function retroactivelySubscribe(address:String, callback:Function):void {
			subscribe(address, callback);
			if (hasBackupFor(address)) {
				callback(recoverBackupFor(address));
				deleteBackupFor(address);
			}
		}

		/**
		 * Prepares the current instance for garbage collection by clearing backups and stopping
		 * observations.
		 */
		public function trash () : void {
			_backups = {};
			_observer.stopObserving ();
		}

		/**
		 * Unsubscribes a callback function from receiving content updates for a specific address within
		 * the pipe.
		 *
		 * @param address The address for which to unsubscribe from receiving content updates.
		 * @param handler Optional. The callback function to unsubscribe. If not provided, all handlers
		 * for the specified address will be unsubscribed.
		 */
		public function unsubscribe (address : String, handler : Function = null) : void {
			_observer.stopObserving (address, handler);
		}

		
		private function _hasSubscribers (address : String) : Boolean {
			return _observer.isObserving (address);
		}
	}
}
