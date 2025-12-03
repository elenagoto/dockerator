import React from 'react';

function RootLayout({ children }) {
  return (
    <html lang='en'>
      <body>
        {children}

        <footer style={{ padding: '2rem', fontFamily: 'system-ui' }}>
          This is the footer for 🎯 $APP_NAME
        </footer>
      </body>
    </html>
  );
}

export default RootLayout;
