import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { Toaster } from 'react-hot-toast'
import Image from 'next/image'
import '../styles/globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'DevoTranscribe - Professional Speech Transcription Service',
  description: 'Upload audio or video files and get accurate transcriptions powered by advanced AI technology.',
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
    title: 'DevoTranscribe - Professional Speech Transcription Service',
    description: 'Upload audio or video files and get accurate transcriptions powered by advanced AI technology.',
    siteName: 'DevoTranscribe',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'DevoTranscribe - Professional Speech Transcription Service',
    description: 'Upload audio or video files and get accurate transcriptions powered by advanced AI technology.',
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
                  <div className="flex items-center space-x-3">
                    <div className="flex-shrink-0">
                      <Image
                        src="/devotranscribe.png"
                        alt="DevoTranscribe Logo"
                        width={120}
                        height={40}
                        className="h-10 w-auto object-contain"
                      />
                    </div>
                    <div>
                      <h1 className="text-xl font-bold text-gray-900">
                        DevoTranscribe
                      </h1>
                      <span className="text-sm text-gray-500">
                        Professional Speech Transcription
                      </span>
                    </div>
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

          {/* Global footer handled in individual pages */}
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
