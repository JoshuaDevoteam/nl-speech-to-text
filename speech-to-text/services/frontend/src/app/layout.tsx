import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { Toaster } from 'react-hot-toast'
import '../styles/globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Speech to Text - Dutch Transcription Service',
  description: 'Upload audio or video files and get accurate Dutch transcriptions using Google Cloud Speech-to-Text.',
  keywords: ['speech to text', 'transcription', 'dutch', 'audio', 'video', 'google cloud'],
  authors: [{ name: 'Devoteam' }],
  viewport: {
    width: 'device-width',
    initialScale: 1,
  },
  robots: {
    index: true,
    follow: true,
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://speech-to-text.devoteam.com',
    title: 'Speech to Text - Dutch Transcription Service',
    description: 'Upload audio or video files and get accurate Dutch transcriptions using Google Cloud Speech-to-Text.',
    siteName: 'Speech to Text Service',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Speech to Text - Dutch Transcription Service',
    description: 'Upload audio or video files and get accurate Dutch transcriptions using Google Cloud Speech-to-Text.',
  },
}

interface RootLayoutProps {
  children: React.ReactNode
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en" className="h-full">
      <body className={`${inter.className} h-full antialiased`}>
        <div className="min-h-full bg-gray-50">
          {/* Header */}
          <header className="bg-white shadow">
            <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
              <div className="flex h-16 justify-between items-center">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <h1 className="text-xl font-bold text-gray-900">
                      Speech to Text
                    </h1>
                  </div>
                  <div className="ml-4">
                    <span className="text-sm text-gray-500">
                      Dutch Transcription Service
                    </span>
                  </div>
                </div>
                
                <div className="flex items-center space-x-4">
                  <span className="text-sm text-gray-500">
                    Powered by Google Cloud
                  </span>
                </div>
              </div>
            </div>
          </header>

          {/* Main content */}
          <main className="flex-1">
            {children}
          </main>

          {/* Footer */}
          <footer className="bg-white border-t">
            <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
              <div className="py-8">
                <div className="flex justify-between items-center">
                  <div className="text-sm text-gray-500">
                    © 2024 Devoteam. All rights reserved.
                  </div>
                  <div className="flex space-x-6">
                    <a 
                      href="#" 
                      className="text-sm text-gray-500 hover:text-gray-900 transition-colors"
                    >
                      Privacy Policy
                    </a>
                    <a 
                      href="#" 
                      className="text-sm text-gray-500 hover:text-gray-900 transition-colors"
                    >
                      Terms of Service
                    </a>
                    <a 
                      href="#" 
                      className="text-sm text-gray-500 hover:text-gray-900 transition-colors"
                    >
                      Support
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </footer>
        </div>

        {/* Toast notifications */}
        <Toaster
          position="top-right"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#363636',
              color: '#fff',
            },
            success: {
              duration: 3000,
              style: {
                background: '#10b981',
              },
            },
            error: {
              duration: 5000,
              style: {
                background: '#ef4444',
              },
            },
          }}
        />
      </body>
    </html>
  )
}