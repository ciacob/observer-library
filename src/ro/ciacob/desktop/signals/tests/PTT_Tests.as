package ro.ciacob.desktop.signals.tests {
	
	import flexunit.framework.Assert;
	
	import ro.ciacob.desktop.signals.PTT;
	
	public class PTT_Tests {
		
		private const PIPE_1 : String = 'testPipeName1';
		private const PIPE_2 : String = 'testPipeName2';
		
		private var _callback1 : Function;
		private var _callback2 : Function;
		private var _result1 : Array;
		private var _result2 : Array;
		
		
		[Before]
		public function setUp() : void {
		}
		
		[After]
		public function tearDown():void {
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void {
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void {
		}
		
		
		// TESTS START HERE
		
		[Test]
		public function testGetPipe():void {
			Assert.assertTrue ('getPipe must return an instance of PTT - 1', PTT.getPipe (PIPE_1) is PTT);
			
			Assert.assertTrue ('getPipe must return an instance of PTT - 2', PTT.getPipe (PIPE_2) is PTT);
			
			Assert.assertFalse (
				'getPipe must return a different PTT instance for different pipe names',
				PTT.getPipe(PIPE_1) === PTT.getPipe(PIPE_2)
			);
			
			Assert.assertTrue (
				'getPipe must return the same PTT instance each time the same pipe name is given',
				PTT.getPipe(PIPE_1) === PTT.getPipe(PIPE_1)
			);
		}
		
		[Test(description="Tests hasBackupFor, recoverBackupFor, deleteBackupFor")]
		public function backupRelatedFunctionality ():void {
			var testPipeName : String = Math.round (Math.random() * 1000000).toString();
			var testPtt : PTT = PTT.getPipe (testPipeName);
			var testAddress : String = 'someAddressOnThePipe';
			var testValue : String = 'someValueToSendOverThePipe';
			
			// Test 1
			Assert.assertFalse (
				'hasBackupFor must return false in lack of any value ever sent throught the pipe',
				testPtt.hasBackupFor (testAddress)
			);
			
			// Test 2
			testPtt.send (testAddress, testValue);
			Assert.assertTrue (
				'hasBackupFor must return true after sending a value through the pipe to an the address no one listens to',
				testPtt.hasBackupFor (testAddress)
			);
			
			// Test 3
			testPtt.subscribe (testAddress, function (...etc) : void {
				Assert.fail (
					'Simply subscribing to an address should not provide the subscriber with the back-up' +
					' of the last value sent to that address, even if there is one'
				);
			});

			// Test 4
			Assert.assertTrue (
				'hasBackupFor must return true even after a listener has become available on the address we sent to' +
				' -- that is, deleting the back-up requires explicit action',
				testPtt.hasBackupFor (testAddress)
			);
			
			// Test 5
			Assert.assertEquals (
				'recoverBackupFor must produce the exact value originally entered into the pipe',
				testPtt.recoverBackupFor (testAddress),
				testValue
			);
			
			// Test 6
			testPtt.deleteBackupFor (testAddress);
			Assert.assertFalse (
				'hasBackupFor must return false after a call to deleteBackupFor has been made',
				testPtt.hasBackupFor (testAddress)
			);
		}
		
		[Test]
		public function transmissionRelatedFunctionality ():void {
			var testPipeNameA : String = Math.round (Math.random() * 1000000).toString();
			var testPipeNameB : String = Math.round (Math.random() * 1000000).toString();
			
			var testPttA : PTT = PTT.getPipe (testPipeNameA);
			var testPttB : PTT = PTT.getPipe (testPipeNameB);
			
			var testAddressA : String = 'addressA';
			var testAddressB : String = 'addressB';
			
			var testValueA : String = 'some value to send over the pipe';
			var testValueB : String = 'some other value to send over the pipe';
			
			var resultsA : Array = [];
			var resultsB : Array = [];
			
			var callbackA : Function = function (value : Object) : void {
				resultsA.push (value);
			};
			var callbackB : Function = function (value : Object) : void {
				resultsB.push (value);
			};
			
			// Test 1
			testPttB.subscribe (testAddressA, callbackA);
			testPttB.send (testAddressA, testValueA);
			Assert.assertEquals (
				'using subscribe and send in proper order, with only one callback, should' +
				' pass the test value unchanged via the pipe and into the callback',
				testValueA,
				resultsA.join ('')
			);
			
			// Test 2
			resultsA.length = 0;
			testPttB.unsubscribe (testAddressA, callbackA);
			testPttB.send (testAddressA, testValueA);
			Assert.assertEquals (
				'calling unsubscribe with both the address and callback as arguments should' +
				' unregister the matching callback listening on that address',
				'',
				resultsA.join ('')
			);
			
			// Test 3
			resultsA.length = 0;
			testPttB.subscribe (testAddressA, callbackA);
			testPttB.subscribe (testAddressA, callbackB);
			testPttB.send (testAddressA, testValueA);
			Assert.assertEquals (
				'using subscribe to register two different callbacks to the same address should have' +
				' both receiving the same value when calling send',
				resultsA.join(''),
				resultsB.join('')
			);
			
			// Test 4
			resultsA.length = 0;
			resultsB.length = 0;
			testPttB.unsubscribe (testAddressA);
			testPttB.send (testAddressA, testValueA);
			Assert.assertEquals (
				'calling unsubscribe with only the address as an argument should unregister the' +
				' all callbacks listening on that address',
				'',
				resultsA.concat (resultsB).join ('')
			);
		}
		
		[Test]
		public function testTrash() : void {
			
			var testPipeName : String = Math.round (Math.random() * 1000000).toString();
			
			var testPtt : PTT = PTT.getPipe (testPipeName);
			
			var testAddress : String = 'address';
			
			var testValue : String = 'some value to send over the pipe';
			
			var results : Array = [];
			
			var testCallback : Function = function (value : Object) : void {
				results.push (value);
			};

			// TEST 1
			testPtt.send (testAddress, testValue);
			testPtt.subscribe (testAddress, testCallback);
			testPtt.trash();
			Assert.assertFalse (
				'hasBackupFor should return false after a call to trash, even if a send operation had just taken place',
				testPtt.hasBackupFor (testAddress)
			);
			
			// TEST 2
			testPtt.send (testAddress, testValue);
			Assert.assertEquals (
				'no callback should fire anymore after a call to trash since it unregisteres everything, on all addresses',
				'',
				results.join ('')
			);
		}
	}
}