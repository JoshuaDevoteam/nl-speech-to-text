export const metadata = {
  title: 'Support',
}

export default function SupportPage() {
  const supportEmail = 'joshua.vink@devoteam.com'

  return (
    <div className="bg-white py-16">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8 text-gray-700">
        <h1 className="text-3xl font-bold text-gray-900">Support</h1>
        <p className="mt-2 text-sm text-gray-500">We are here to help.</p>

        <section className="mt-8 space-y-4">
          <p>
            For questions about uploads, transcripts, or billing, contact Joshua directly. You will
            receive a reply as quickly as possible during standard business hours in Central European Time.
          </p>
          <div className="rounded-lg border border-primary-100 bg-primary-50 p-6 text-sm text-gray-700">
            <p className="font-medium text-primary-800">Email Support</p>
            <a
              href={`mailto:${supportEmail}`}
              className="mt-1 inline-block text-primary-600 hover:underline"
            >
              {supportEmail}
            </a>
            <p className="mt-2 text-xs text-primary-700">
              Please include your job ID or filename when requesting assistance so we can respond quickly.
            </p>
          </div>
        </section>
      </div>
    </div>
  )
}
