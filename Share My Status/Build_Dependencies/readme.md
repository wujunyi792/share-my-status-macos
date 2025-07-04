# MediaRemote Permission Bypass Solution

## Background

Due to Apple's adjustment of MediaRemote usage permissions in macOS 15.4 and above, users can no longer directly utilize MediaRemote to retrieve Now Playing content from the system.

## Solution

The project [ungive/mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) provides a method to bypass this restriction:

- Uses the system's built-in Perl which has the necessary permissions
- Dynamically loads a custom helper framework to call MediaRemote
- Outputs real-time update information to stdout

## Usage

To use this method, you need to incorporate the open-source components from the aforementioned project:

1. **Perl script** - Universal component that can be used directly
2. **adapter.framework** - May need to be compiled for different platforms

## Notes

- `adapter.framework` may require compilation for different platforms
- For detailed usage instructions, please refer to the [project documentation](https://github.com/ungive/mediaremote-adapter)

## References

- [MediaRemote Adapter Project](https://github.com/ungive/mediaremote-adapter)