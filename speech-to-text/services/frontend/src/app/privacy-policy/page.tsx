export const metadata = {
  title: 'Privacy Policy',
}

export default function PrivacyPolicyPage() {
  return (
    <div className="bg-white py-16">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900">Privacy Policy</h1>
        <p className="mt-2 text-sm text-gray-500">Effective date: January 1, 2025</p>

        <section className="mt-8 space-y-4 text-gray-700">
          <p>
            This privacy policy explains how we collect, use, and protect information when you
            use the Dutch Speech to Text service.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Information We Collect</h2>
          <p>
            We collect the files you upload for transcription, related metadata, and limited usage
            analytics to improve reliability and performance. Files are stored securely in Google Cloud
            Storage and are processed solely for transcription purposes.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">How We Use Information</h2>
          <p>
            Uploaded content is used to generate transcriptions and improve speaker identification.
            We do not sell or share your content with third parties. Access is restricted to authorized
            team members who maintain the service.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Data Retention</h2>
          <p>
            Transcripts and uploaded media may be retained to support processing, auditing, and quality
            assurance. You can request deletion at any time by contacting support.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Your Rights</h2>
          <p>
            You may request access to, correction of, or deletion of your data. Contact
            <a href="mailto:joshua.vink@devoteam.com" className="ml-1 text-primary-600 hover:underline">joshua.vink@devoteam.com</a>
            to submit a request.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Contact</h2>
          <p>
            For questions about this policy, email
            <a href="mailto:joshua.vink@devoteam.com" className="ml-1 text-primary-600 hover:underline">joshua.vink@devoteam.com</a>.
          </p>
        </section>
      </div>
    </div>
  )
}
