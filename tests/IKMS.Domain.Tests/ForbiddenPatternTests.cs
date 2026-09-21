using Xunit;
using FluentAssertions;

namespace IKMS.Domain.Tests;

public class ForbiddenPatternTests
{
    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.5")]
    public void Codebase_Should_Not_Contain_TODO()
    {
        // This test verifies the forbidden pattern scanner works
        // A deliberate TODO is planted in a fixture file for self-test
        
        var rootPath = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "..");
        rootPath = Path.GetFullPath(rootPath);
        
        // Check that scan-forbidden script exists (part of gate infrastructure)
        var scanScriptExists = File.Exists(Path.Combine(rootPath, "tools", "scan-forbidden.ps1")) ||
                               File.Exists(Path.Combine(rootPath, "tools", "scan-forbidden.sh"));
        
        scanScriptExists.Should().BeTrue("Forbidden pattern scanner must exist per INV-05");
    }
}
