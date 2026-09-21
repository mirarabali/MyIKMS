using System.Text.RegularExpressions;

namespace IKMS.Application.Services;

/// <summary>
/// User service implementation (Application layer)
/// </summary>
public class UserService : IUserService
{
    private const int MAX_USERNAME_LENGTH = 255;
    
    /// <inheritdoc/>
    public bool IsValidUserName(string? userName, out string errorMessage)
    {
        if (string.IsNullOrWhiteSpace(userName))
        {
            errorMessage = "User name is required (User_UserName NN per schema).";
            return false;
        }
        
        if (userName.Length > MAX_USERNAME_LENGTH)
        {
            errorMessage = $"User name cannot exceed {MAX_USERNAME_LENGTH} characters (nvarchar(255) per schema).";
            return false;
        }
        
        errorMessage = string.Empty;
        return true;
    }
    
    /// <inheritdoc/>
    /// <remarks>
    /// Placeholder for Argon2id hashing. Actual implementation requires Konscious.Security.Cryptography.Argon2 package.
    /// Per DEC-04: memory=65536, iterations=3, parallelism=4
    /// </remarks>
    public string HashPassword(string plainPassword)
    {
        // TODO: Implement Argon2id hashing with Konscious.Security.Cryptography.Argon2
        // For now, return a placeholder that will be replaced in Phase 2
        throw new NotImplementedException("Argon2id hashing to be implemented in Phase 2");
    }
    
    /// <inheritdoc/>
    public bool VerifyPassword(string plainPassword, string hashedPassword)
    {
        // TODO: Implement Argon2id verification
        throw new NotImplementedException("Argon2id verification to be implemented in Phase 2");
    }
}
