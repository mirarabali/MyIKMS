using Xunit;
using FluentAssertions;

namespace IKMS.Domain.Tests;

public class MigrationGuardTests
{
    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.2")]
    public void Migrations_Folder_Must_Be_Empty()
    {
        // Arrange
        var migrationsPath = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "..", "src", "IKMS.Infrastructure", "Migrations");
        
        // Normalize path
        migrationsPath = Path.GetFullPath(migrationsPath);
        
        // Act
        var hasMigrations = Directory.Exists(migrationsPath) && 
            Directory.GetFiles(migrationsPath, "*.cs").Any(f => !f.EndsWith("_EFMigrationsHistory.cs"));

        // Assert
        hasMigrations.Should().BeFalse("Migrations folder must be empty per INV-02");
    }
}
