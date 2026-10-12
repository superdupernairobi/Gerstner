--!strict
const G = 196.2

--[=[
	A single wave definition

	@interface Wave
	@within Gerstner
	.wavelength number -- Studs between crests
	.amplitude number -- Crest height in studs
	.steepness number -- 0..1; 0 = pure sine swell, 1 = sharpest allowed
	.direction Vector2 -- Travel direction; need not be normalised
]=]
export type Wave = {
	wavelength: number,
	amplitude: number,
	steepness: number,
	direction: Vector2,
}

--[=[
	Precomputed per wave constants

	@interface PreparedWave
	@within Gerstner
	@private
]=]
type PreparedWave = {
	kx: number,
	kz: number,
	omega: number,
	xa: number,
	za: number,
	a: number,
}

--[=[
	Precomputed wave data returned by [Gerstner.prepare]

	@interface Prepared
	@within Gerstner
	.waves {PreparedWave} -- Precomputed constants, one per input wave
	.steepness number -- Average steepness across all waves, 0..1
]=]
export type Prepared = {
	waves: { PreparedWave },
	steepness: number,
}

export type Gerstner = {
	prepare: (waves: { Wave }) -> Prepared,
	displace: (prepared: Prepared, x: number, z: number, t: number) -> Vector3,
}

--[=[
	Validates a wave set once and precomputes every wave constant

	@function prepare
	@within Gerstner
	@param waves {Wave} -- The wave definitions to prepare
	@return Prepared -- Precomputed waves plus the average steepness
	@error "needs at least one wave" -- Raised when 'waves' is empty
]=]
const function prepare(waves: { Wave }): Prepared
	local count = #waves
	
	if count == 0 then
		error("gerstner.prepare: needs at least one wave")
	end
	
	const prepared: { PreparedWave } = {}
	local steepnessSum = 0
	
	for i, wave in waves do
		const wavelength = wave.wavelength
		const amplitude = wave.amplitude
		const steepness = wave.steepness
		
		if wavelength <= 0 then
			error(`gerstner.prepare: wave {i} wavelength must be greater than 0`)
		end
		
		if amplitude <= 0 then
			error(`gerstner.prepare: wave {i} amplitude must be greater than 0`)
		end
		
		if steepness < 0 or steepness > 1 then
			error(`gerstner.prepare: wave {i} steepness must be between 0 and 1`)
		end
		
		const direction = wave.direction
		const length = direction.Magnitude
		
		if length == 0 then
			error(`gerstner.prepare: wave {i} direction must not be zero`)
		end
		
		const dirX = direction.X / length
		const dirY = direction.Y / length
		
		const k = 2 * math.pi / wavelength
		const omega = math.sqrt(G * k)
		
		const q = steepness / (k * amplitude * count)
		
		steepnessSum += steepness	
		
		prepared[i] = {
			kx = k * dirX,
			kz = k * dirY,
			omega = omega,
			xa = q * amplitude * dirX,
			za = q * amplitude * dirY,
			a = amplitude,
		}
	end
	
	return {
		waves = prepared,
		steepness = steepnessSum / count,
	}
end

--[=[
	Returns the absolute world position of the surface point whose
	rest position is '(x, z)'. 'y' is relative to the water plane's own
	level; the renderer adds sea level

	@function displace
	@within Gerstner
	@param prepared Prepared -- The result of [Gerstner.prepare]
	@param x number -- Rest position X in studs
	@param z number -- Rest position Z in studs
	@param t number -- Time in seconds
	@return Vector3 -- Absolute displaced position
]=]
const function displace(prepared: Prepared, x: number, z: number, t: number): Vector3
	local dx, dy, dz = 0, 0, 0
	
	for _, wave in prepared.waves do
		const phase = wave.kx * x + wave.kz * z - wave.omega * t
		const c = math.cos(phase)
		
		dx += wave.xa * c
		dz += wave.za * c
		dy += wave.a * math.sin(phase)
	end
	
	return Vector3.new(x + dx, dy, z + dz)
end

--[=[
	Pure Gerstner wave displacement. No instances or states

	@class Gerstner
]=]
const gerstner = table.freeze({
	prepare = prepare,
	displace = displace,
}) :: Gerstner

return gerstner