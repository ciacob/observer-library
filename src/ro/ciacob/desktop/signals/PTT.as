/*//////////////////////////////////////////////////////////////////*/
/*                                                                  */
/*   Unless stated otherwise, all work presented in this file is    */
/*   the intelectual property of:                                   */
/*   @author Claudius Iacob <claudius.iacob@gmail.com>              */
/*                                                                  */
/*   All rights reserved. Obtain written permission from the author */
/*   before using/reusing/adapting this code in any way.            */
/*                                                                  */
/*//////////////////////////////////////////////////////////////////*/

package ro.ciacob.desktop.signals {


	/**
	 * PTT (for Pneumatic Tube Transport, the late 19th / early 20th century compressed air postal
	 * networks) is a class internally using an implementaion of IObserver. It is intended to
	 * replace the AS3 bubbling event model with some simpler, leaner and more straight forward way
	 * of passing information around, while keeping all the communicating participants uncoupled.
	 * Maybe most importantly, the PTT system is SYNCHRONOUS.
	 *
	 * Supports PIPES for isolating/directing the flow to a specific (range) of subscribers only.
	 *
	 * Examples: 
	 * 
	 * <code>
	 *
	 * 		// Sending out information
	 * 		PTT.getPipe(pipeName).send (address, content);
	 *
	 * 		// Subscribing to receive a certain content
	 * 		PPT.getPipe(pipeName).subscribe (address, handler);
	 *
	 * 		// Unsubscribing
	 * 		PPT.getPipe(pipeName).unsubscribe (address, handler);
	 *
	 * 		// Pickup last delivery - lets late subscribers access the last content sent to a specific address
	 * 		if (PPT.getPipe(pipeName).hasBackupFor(address)) {
	 * 			PPT.getPipe(pipeName).recoverBackupFor (address);
	 * 		}
	 * 
	 * 		// Discard back-ups of last derivery
	 * 		if (PPT.getPipe(pipeName).hasBackupFor(address)) {
	 * 			PPT.getPipe(pipeName).deleteBackupFor (address);
	 * 		}
	 *
	 * 		// Prepare for garbage collection
	 * 		PPT.getPipe(pipeName).trash();
	 *
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
		 * Retrieves a PTT instance for transmitting content through. If ommitted, defaults to the
		 * default (public) instance. Note that there is no publicly accessible list of pipe
		 * instances.
		 *
		 * @param	uid The name of a pipe. Accepted values are Strings, numericals, or any instance
		 *                     containing a `toString()` member function. `Null` is assumed for
		 *                     non-accepted values.
		 *
		 * @return	A discreet PTT instance corresponding to given pipe name.
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
		 * @see PTT Documentation of `PTT` class
		 */
		public function PTT () {
			if (_requestedPipe == null || _pipes[_requestedPipe] != null) {
				throw (new Error ('The PTT class cannot be initialized directly. Use `PTT.getPipe("myPipe")` instead.'));
			}
			_observer = new Observer;
			_backups = {};
		}

		public function deleteBackupFor (address : String) : void {
			if (hasBackupFor (address)) {
				delete _backups[address];
			}
		}

		public function hasBackupFor (address : String) : Boolean {
			return (address in _backups);
		}

		public function recoverBackupFor (address : String) : Object {
			if (hasBackupFor (address)) {
				return _backups[address];
			}
			return null;
		}

		public function send (address : String, content : Object = null) : void {
			if (_hasSubscribers (address)) {
				_observer.notifyChange (address, content);
			} else {
				_backups[address] = content;
			}
		}

		public function subscribe (address : String, handler : Function) : void {
			if (handler == null) {
				throw(new ArgumentError ('PTT.subscribe: argument `handler` cannot be missing.'));
			}
			_observer.observe (address, handler);
		}

		/**
		 * Prepares the current instance for garbage collection.
		 */
		public function trash () : void {
			_backups = {};
			_observer.stopObserving ();
		}

		/**
		 * @param addr
		 * 		  Unique value to refer to an address on the current pipe. Valid types are String, int, uint and Number.
		 */
		public function unsubscribe (address : String, handler : Function = null) : void {
			_observer.stopObserving (address, handler);
		}

		
		private function _hasSubscribers (address : String) : Boolean {
			return _observer.isObserving (address);
		}
	}
}
