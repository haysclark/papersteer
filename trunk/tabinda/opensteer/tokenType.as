// ----------------------------------------------------------------------------
//
// OpenSteer - Action Script 3 Port
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
//
// OpenSteer -- Steering Behaviors for Autonomous Characters
//
// Copyright (c) 2002-2003, Sony Computer Entertainment America
// Original author: Craig Reynolds <craig_reynolds@playstation.sony.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
// ----------------------------------------------------------------------------

package tabinda.opensteer
{
	// "token" to represent objects stored in the database
	public class tokenType extends AbstractTokenForProximityDatabase
	{
		var proxy:lqClientProxy;
		var lq:locationQueryDatabase;

		// constructor
		public function tokenType(parentObject:Object,lqsd:LQProximityDatabase)
		{
			proxy=new lqClientProxy(parentObject);// lqInitClientProxy(proxy, parentObject);
			lq=lqsd.lq;
		}

		// destructor
		// ~tokenType()
		//{
		//    lq.lqRemoveFromBin(proxy);
		//}

		// the client object calls this each time its position changes
		public override function updateForNewPosition(p:Vector3):void
		{
			lq.lqUpdateForNewLocation(proxy,p.x,p.y,p.z);
		}

		// find all neighbors within the given sphere (as center and radius)
		public override function findNeighbors(center:Vector3,radius:Number,results:Array):void
		{
			//lqMapOverAllObjectsInLocality(lq,

			var tList:Array=lq.getAllObjectsInLocality(center.x,center.y,center.z,radius);
			for (var i:int=0; i < tList.length; i++)
			{
				var tProxy:lqClientProxy=lqClientProxy(tList[i]);
				//tList.ForEach(delegate(lqClientProxy tProxy)
				//{
				results.push(AbstractVehicle(tProxy.clientObject));
				//});
			}
		}

		// called by LQ for each clientObject in the specified neighborhood:
		// push that clientObject onto the ContentType vector in void*
		// clientQueryState
		// (parameter names commented out to prevent compiler warning from "-W")


/*
            static void perNeighborCallBackFunction(void* clientObject,
                                                      float distanceSquared,
                                                      void* clientQueryState)
            {
                typedef std::vector<ContentType> ctv;
                ctv& results = *((ctv*) clientQueryState);
                results.push_back ((ContentType) clientObject);
            }
            */


	}


	// allocate a token to represent a given client object in this database
	public override  function allocateToken(parentObject:AbstractVehicle):AbstractTokenForProximityDatabase
	{
		return new tokenType(parentObject,this);
	}

	// count the number of tokens currently in the database
	public override  function getPopulation():int
	{
		//int count = 0;
		//lqMapOverAllObjects(lq, counterCallBackFunction, &count);

		var count:int=lq.getAllObjects().length;

		return count;
	}

	public override  function getNearestVehicle(position:Vector3,radius:Number):AbstractVehicle
	{
		var tProxy:lqClientProxy=lq.lqFindNearestNeighborWithinRadius(position.x,position.y,position.z,radius,null);
		var tVehicle:AbstractVehicle=null;
		if (tProxy != null)
		{
			tVehicle=AbstractVehicle(tProxy.clientObject);
		}
		return tVehicle;
	}

	public override  function getMostPopulatedBinCenter():Vector3
	{
		return lq.getMostPopulatedBinCenter();
	}
}