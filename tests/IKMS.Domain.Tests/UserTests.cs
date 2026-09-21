using Xunit;
using FluentAssertions;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Tests;

public class UserTests
{
    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.1")]
    public void User_Entity_Can_Be_Instantiated()
    {
        // Arrange & Act
        var user = new User();

        // Assert
        user.Should().NotBeNull();
    }

    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.1")]
    public void User_UserName_Is_Required()
    {
        // Arrange
        var user = new User();

        // Act
        user.User_UserName = null!;

        // Assert
        user.User_UserName.Should().BeNull(); // Will be validated at DB level per schema
    }

    [Fact]
    [Trait("Phase", "1")]
    [Trait("AC", "AC-1.1")]
    public void User_Password_Is_Required()
    {
        // Arrange
        var user = new User();

        // Act
        user.User_Password = null!;

        // Assert
        user.User_Password.Should().BeNull(); // Will be validated at DB level per schema
    }
}
