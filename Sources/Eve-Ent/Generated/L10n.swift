// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Account {
    internal enum NavigationBar {
      /// Account
      internal static let title = L10n.tr("Localizable", "Account.NavigationBar.Title")
    }
    internal enum TabBar {
      /// Account
      internal static let title = L10n.tr("Localizable", "Account.TabBar.Title")
    }
  }

  internal enum Authorization {
    internal enum EmailTextField {
      /// Email
      internal static let placeholder = L10n.tr("Localizable", "Authorization.EmailTextField.Placeholder")
    }
    internal enum PasswordTextField {
      /// Password
      internal static let placeholder = L10n.tr("Localizable", "Authorization.PasswordTextField.Placeholder")
    }
    internal enum SignInButton {
      /// Sign In
      internal static let title = L10n.tr("Localizable", "Authorization.SignInButton.Title")
    }
  }

  internal enum Common {
    /// Save
    internal static let save = L10n.tr("Localizable", "Common.Save")
  }

  internal enum EditProfile {
    /// First Name
    internal static let firstNameHint = L10n.tr("Localizable", "EditProfile.FirstNameHint")
    /// Last Name
    internal static let lastNameHint = L10n.tr("Localizable", "EditProfile.LastNameHint")
    internal enum NavigationBar {
      /// Edit Profile
      internal static let title = L10n.tr("Localizable", "EditProfile.NavigationBar.Title")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
