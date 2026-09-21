namespace IKMS.Application.Services;

/// <summary>
/// User service interface for application layer
/// </summary>
public interface IUserService
{
    /// <summary>
    /// Validates a user name according to schema constraints (nvarchar(255) NN)
    /// </summary>
    bool IsValidUserName(string? userName, out string errorMessage);
    
    /// <summary>
    /// Hashes a password using Argon2id (per DEC-04)
    /// </summary>
    string HashPassword(string plainPassword);
    
    /// <summary>
    /// Verifies a password against a hash
    /// </summary>
    bool VerifyPassword(string plainPassword, string hashedPassword);
}
