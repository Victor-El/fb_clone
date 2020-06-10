String getUsernameFromEmail(String email) {
  return email.substring(0, email.indexOf("@"));
}