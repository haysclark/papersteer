package tabinda.opensteer
{
	public class lqClientProxy
	{
		// Active bin 
		public var bin:lqBin=null;

		// Pointer to client object
		public var clientObject:Object;

		//* The object's location ("key point") used for spatial sorting
		public var x:Number;
		public var y:Number;
		public var z:Number;

		public function lqClientProxy(tClientObject:Object)
		{
			clientObject=tClientObject;
			x=0.0;
			y=0.0;
			z=0.0;
		}
	}
}