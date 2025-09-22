import type { Meta, StoryObj } from '@storybook/react'
import { fn } from '@storybook/test'
import TranscriptionResult from '@/components/TranscriptionResult'
import type { TranscriptionState } from '@/types/transcription'

const onNewUploadAction = fn<() => void>()

const meta = {
  title: 'Components/TranscriptionResult',
  component: TranscriptionResult,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A component to display transcription results with copy, download, and metadata features.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    onNewUpload: {
      description: 'Callback function for starting a new upload',
      action: 'newUpload',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes to apply',
    },
  },
  args: {
    onNewUpload: onNewUploadAction,
  },
} satisfies Meta<typeof TranscriptionResult>

export default meta
type Story = StoryObj<typeof meta>

const sampleTranscript = `Goedemiddag, welkom bij onze vergadering van vandaag. Ik ben blij dat iedereen aanwezig kan zijn. Laten we beginnen met de agenda van vandaag. Als eerste punt bespreken we de voortgang van het project. Daarna gaan we over naar de budgetbesprekingen en ten slotte bespreken we de planning voor het volgende kwartaal.`

const longTranscript = `${sampleTranscript} `.repeat(10) + `Dit is een veel langere transcriptie die demonstreert hoe de component omgaat met langere teksten. De component moet een "Show more" functionaliteit bieden wanneer de tekst te lang wordt. Dit helpt om de interface schoon en overzichtelijk te houden, terwijl gebruikers nog steeds toegang hebben tot de volledige transcriptie wanneer ze dat nodig hebben.`

export const BasicResult: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-12345',
      status: 'completed',
      transcript: sampleTranscript,
      createdAt: new Date(Date.now() - 120000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/audio-file.mp3',
    } satisfies TranscriptionState,
  },
  parameters: {
    docs: {
      description: {
        story: 'Basic transcription result with a short transcript.',
      },
    },
  },
}

export const LongTranscript: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-67890',
      status: 'completed',
      transcript: longTranscript,
      createdAt: new Date(Date.now() - 300000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/long-audio-file.mp3',
      transcriptUri: 'gs://bucket/transcripts/transcript-67890.txt',
    } satisfies TranscriptionState,
  },
  parameters: {
    docs: {
      description: {
        story: 'Transcription result with a long transcript that can be expanded/collapsed.',
      },
    },
  },
}

export const WithoutNewUploadButton: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-11111',
      status: 'completed',
      transcript: sampleTranscript,
      createdAt: new Date(Date.now() - 60000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/audio-file.mp3',
    } satisfies TranscriptionState,
    onNewUpload: undefined,
  },
  parameters: {
    docs: {
      description: {
        story: 'Transcription result without the "New Upload" button.',
      },
    },
  },
}

export const WithTranscriptUri: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-22222',
      status: 'completed',
      transcript: sampleTranscript,
      transcriptUri: 'gs://bucket/transcripts/transcript-22222.txt',
      createdAt: new Date(Date.now() - 180000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/audio-file.wav',
    } satisfies TranscriptionState,
  },
  parameters: {
    docs: {
      description: {
        story: 'Transcription result with a saved transcript URI for additional reference.',
      },
    },
  },
}

export const RecentCompletion: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-33333',
      status: 'completed',
      transcript: 'Hallo, dit is een korte test transcriptie.',
      createdAt: new Date(Date.now() - 10000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/test-audio.mp3',
    } satisfies TranscriptionState,
  },
  parameters: {
    docs: {
      description: {
        story: 'Recently completed transcription showing very short processing time.',
      },
    },
  },
}

export const WithCustomClassName: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-44444',
      status: 'completed',
      transcript: sampleTranscript,
      createdAt: new Date(Date.now() - 90000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/custom-audio.mp3',
    } satisfies TranscriptionState,
    className: 'max-w-2xl',
  },
  parameters: {
    docs: {
      description: {
        story: 'Transcription result with custom styling applied.',
      },
    },
  },
}

// Interactive example
export const Interactive: Story = {
  args: {
    transcriptionState: {
      jobId: 'job-interactive',
      status: 'completed',
      transcript: longTranscript,
      createdAt: new Date(Date.now() - 240000).toISOString(),
      completedAt: new Date().toISOString(),
      gcsUri: 'gs://bucket/interactive-demo.mp4',
      transcriptUri: 'gs://bucket/transcripts/interactive-demo.txt',
    } satisfies TranscriptionState,
  },
  render: (args) => (
    <TranscriptionResult
      {...args}
      onNewUpload={() => {
        alert('New upload requested!')
        args.onNewUpload?.()
      }}
    />
  ),
  parameters: {
    docs: {
      description: {
        story: 'Try clicking the copy, download, and new upload buttons to see the interactions.',
      },
    },
  },
}
