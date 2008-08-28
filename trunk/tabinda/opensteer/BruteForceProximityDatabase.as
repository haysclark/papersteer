package tabinda.opensteer
{	
	public class BruteForceProximityDatabase extends AbstractProximityDatabase
	{

		// STL vector containing all tokens in database
		public var group:Array;

		// constructor
		public function BruteForceProximityDatabase()
		{
			group=new Array()  ;
		}

		// allocate a token to represent a given client object in this database
		//public override tokenType allocateToken (Object parentObject)
		public override  function allocateToken(parentObject:AbstractVehicle):AbstractTokenForProximityDatabase
		{

			var tToken:tokenType=new tokenType(parentObject,this);
			return AbstractTokenForProximityDatabase(tToken);
		}

		// return the number of tokens currently in the database
		public override  function getPopulation():int
		{
			return group.size;//.size();
		}
	}
}