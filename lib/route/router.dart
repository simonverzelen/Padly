import 'package:flutter/material.dart';
import 'package:padly/entry_point.dart';
import 'package:padly/screens/games/games.dart';
import 'package:padly/screens/players/players.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

import '../screens/auth/views/password_recovery.dart';
import '../screens/games/src/view/overview/add_players_overview.dart';
import '../screens/onbording/views/select_sports_screen.dart';
import '../screens/onbording/views/select_levels_screen.dart';
import '../screens/games/src/view/overview/find_match_screen.dart';
import '../screens/games/src/view/overview/requests_overview.dart';
import '../screens/games/src/view/detail/search_club_screen.dart';
import 'screen_export.dart';


Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const OnBordingScreen(),
          ],
        ),
      );
    // case preferredLanuageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const PreferredLanguageScreen(),
    //   );
    case notificationPermissionScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const NotificationsScreen(),
          ],
        ),
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const LoginScreen(),
          ],
        ),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const SignUpScreen(),
          ],
        ),
      );
    // case profileSetupScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ProfileSetupScreen(),
    //   );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const PasswordRecoveryScreen(),
          ],
        ),
      );
    case passwordResetScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const PasswordResetScreen(),
          ],
        ),
      );
    // case verificationMethodScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const VerificationMethodScreen(),
    //   );
    // case otpScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const OtpScreen(),
    //   );
    // case newPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetNewPasswordScreen(),
    //   );
    // case doneResetPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DoneResetPasswordScreen(),
    //   );
    // case termsOfServicesScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const TermsOfServicesScreen(),
    //   );
    // case noInternetScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const NoInternetScreen(),
    //   );
    // case serverErrorScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ServerErrorScreen(),
    //   );
    // case signUpVerificationScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SignUpVerificationScreen(),
    //   );
    // case setupFingerprintScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFingerprintScreen(),
    //   );
    // case setupFaceIdScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFaceIdScreen(),
    //   );
    case chatScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const ChatScreen(),
          ],
        ),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const EntryPoint(),
          ],
        ),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const ProfileScreen(),
          ],
        ),
      );
    case createGameScreenRoute:
      final createArgs = settings.arguments as Map<String, dynamic>? ?? {};
      final Game? initialGame = createArgs['game'] as Game?;
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            CreateMatchScreen(initialGame: initialGame),
          ],
        ),
      );
    case searchClubScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const SearchClubScreen(),
          ],
        ),
      );
    case addPlayersScreenRoute:
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      // maxPlayers is the actual player count (2 or 4), not an index.
      // create_game_screen.dart passes vm.playersAmount which is the index into
      // playersAmountList; router.dart converts it to the real count here.
      final int? rawMaxPlayers = args['maxPlayers'] as int?;
      final List<String> playersAmountList = ['2', '4'];
      final int maxPlayers = (rawMaxPlayers != null &&
              rawMaxPlayers >= 0 &&
              rawMaxPlayers < playersAmountList.length)
          ? int.parse(playersAmountList[rawMaxPlayers])
          : 4;
      final List<PadlyUser> initialPlayers =
          args['initialPlayers'] as List<PadlyUser>? ?? [];
      final String? lockedPlayerId = args['lockedPlayerId'] as String?;

      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            AddPlayersOverview(
              maxPlayers: maxPlayers,
              initialPlayers: initialPlayers,
              userService: UserService(),
              lockedPlayerId: lockedPlayerId,
            ),
          ],
        ),
      );
    case gameDetailScreenRoute:
      final args = settings.arguments;
      final Game? game =
          (args is Map<String, dynamic>) ? args['game'] as Game? : null;
      final PadlyUser? initialUser =
          (args is Map<String, dynamic>) ? args['currentUser'] as PadlyUser? : null;

      if (game == null) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                'Match niet gevonden.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      }

      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            GameDetailScreen(
              game: game,
              initialUser: initialUser,
            ),
          ],
        ),
      );
    case gameRequestsScreenRoute:
      final requestArgs = settings.arguments as GameRequestsArgs;
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            RequestsOverview(args: requestArgs),
          ],
        ),
      );
    // case getHelpScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const GetHelpScreen(),
    //   );
    // case chatScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ChatScreen(),
    //   );
    case userInfoScreenRoute:
      final bool isEditable = settings.arguments as bool? ?? false;
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            UserInfoScreen(
              isEditable: isEditable,
            ),
          ],
        ),
      );
    case playerDetailScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const PlayerDetailScreen(),
          ],
        ),
      );
    // case currentPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CurrentPasswordScreen(),
    //   );
    // case editUserInfoScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const EditUserInfoScreen(),
    //   );
    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case locationPermissionScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LocationPermissionScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );
    case selectLanguageScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            SelectLanguageScreen(),
          ],
        ),
      );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );
    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case findMatchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const FindMatchScreen(),
          ],
        ),
      );
    case selectSportsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const SelectSportsScreen(),
          ],
        ),
      );
    case selectLevelsScreenRoute:
      final selectedSports =
          settings.arguments as List<String>? ?? const [];
      return MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            SelectLevelsScreen(selectedSports: selectedSports),
          ],
        ),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            const OnBordingScreen(),
          ],
        ),
      );
  }
}
