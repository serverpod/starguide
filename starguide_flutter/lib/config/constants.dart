const kMaxChatRequests = 10;
const kMaxChatRequestLength = 1000;

/// Name of the scope granted to admin users by the server. Matches
/// `Scope.admin` in Serverpod.
const kAdminScopeName = 'serverpod.admin';

/// The widest the chat is laid out, on a display that is wider. A line of
/// text much longer than this is hard to follow, and the input and footer
/// stay directly under the messages.
const kMaxContentWidth = 800.0;

/// Below this width, the chat is laid out for a phone: the button labels are
/// shortened and the footer only shows what fits.
const kNarrowScreenWidth = 600.0;
