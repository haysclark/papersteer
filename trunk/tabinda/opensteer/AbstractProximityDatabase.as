package tabinda.opensteer
{	
	public class AbstractProximityDatabase
	{


		// type for the "tokens" manipulated by this spatial database
		//typedef AbstractTokenForProximityDatabase<ContentType> tokenType;

		// allocate a token to represent a given client object in this database
		public function allocateToken(parentObject:AbstractVehicle):AbstractTokenForProximityDatabase
		{
			return new AbstractTokenForProximityDatabase  ;
		}

		// returns the number of tokens in the proximity database
		public function getPopulation():int
		{
			return 0;
		}

		public function getNearestVehicle(position:Vector3,radius:Number):AbstractVehicle
		{
			return null;
		}

		public function getMostPopulatedBinCenter():Vector3
		{
			return Vector3.ZERO;
		}

	}
}