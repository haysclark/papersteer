package tabinda.opensteer
{
	public class Obstacle
	{
		public function seenFrom():seenFromState
		{
			// Err not sure what best to do here
			return seenFromState.inside;
		}
		public function setSeenFrom(s:seenFromState):void
		{
		}

		// XXX 4-23-03: Temporary work around (see comment above)
		// CHANGED FROM ABSTRACTVEHICLE. PROBLY SHOULD CHANGE BACK!
		public function steerToAvoid(v:Object,minTimeToCollision:Number):Vector3
		{
			return Vector3.ZERO;
		}

	}
}