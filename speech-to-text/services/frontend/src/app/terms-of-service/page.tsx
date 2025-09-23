export const metadata = {
  title: 'Terms of Service',
}

export default function TermsOfServicePage() {
  return (
    <div className="bg-white py-16">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900">Terms of Service</h1>
        <p className="mt-2 text-sm text-gray-500">Effective date: January 1, 2025</p>

        <section className="mt-8 space-y-4 text-gray-700">
          <p>
            These terms govern your access to and use of the Dutch Speech to Text service. By
            uploading files or using generated transcriptions, you agree to these conditions.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Use of Service</h2>
          <p>
            You may upload audio or video files that you have the right to process. You are responsible
            for ensuring your content complies with applicable laws and does not infringe on the rights of others.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Service Availability</h2>
          <p>
            We aim to maintain high availability but do not guarantee uninterrupted access. Maintenance,
            updates, or external factors may result in downtime.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Intellectual Property</h2>
          <p>
            You retain ownership of content you upload. Generated transcripts are provided for your use,
            and we claim no ownership over them.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Limitation of Liability</h2>
          <p>
            The service is provided "as is" without warranties. To the fullest extent permitted by law,
            we are not liable for indirect, incidental, or consequential damages arising from service use.
          </p>

          <h2 className="text-xl font-semibold text-gray-900">Contact</h2>
          <p>
            Questions about these terms can be directed to
            <a href="mailto:joshua.vink@devoteam.com" className="ml-1 text-primary-600 hover:underline">joshua.vink@devoteam.com</a>.
          </p>
        </section>
      </div>
    </div>
  )
}
