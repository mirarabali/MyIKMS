using Xunit;
using FluentAssertions;
using IKMS.Application.Services;

namespace IKMS.Application.Tests;

public class UserServiceTests
{
    private readonly UserService _userService;

    public UserServiceTests()
    {
        _userService = new UserService();
    }

    [Theory]
    [InlineData("admin", true)]
    [InlineData("test_user", true)]
    [InlineData("user@domain.com", true)]
    [InlineData("", false)]
    [InlineData("   ", false)]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.3")]
    public void IsValidUserName_Validates_Correctly(string? userName, bool expectedValid)
    {
        // Act
        var isValid = _userService.IsValidUserName(userName, out var errorMessage);

        // Assert
        isValid.Should().Be(expectedValid);
        if (!expectedValid)
        {
            errorMessage.Should().NotBeNullOrEmpty();
        }
    }

    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.3")]
    public void IsValidUserName_Rejects_Too_Long_Username()
    {
        // Arrange
        var longUserName = new string('a', 256);

        // Act
        var isValid = _userService.IsValidUserName(longUserName, out var errorMessage);

        // Assert
        isValid.Should().BeFalse();
        errorMessage.Should().Contain("255");
    }

    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.4")]
    public void HashPassword_NotImplemented_In_Phase1()
    {
        // Act & Assert
        _userService.Invoking(u => u.HashPassword("test"))
            .Should().Throw<NotImplementedException>()
            .WithMessage("*Phase 2*");
    }

    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.4")]
    public void VerifyPassword_NotImplemented_In_Phase1()
    {
        // Act & Assert
        _userService.Invoking(u => u.VerifyPassword("test", "hash"))
            .Should().Throw<NotImplementedException>()
            .WithMessage("*Phase 2*");
    }
}
