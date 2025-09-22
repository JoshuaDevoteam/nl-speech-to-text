import type { Meta, StoryObj } from '@storybook/react'
import ProgressBar from '@/components/ProgressBar'
import type { TranscriptionState } from '@/types/transcription'

const meta = {
  title: 'Components/ProgressBar',
  component: ProgressBar,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A progress bar component with support for transcription status and animations.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    progress: {
      control: { type: 'range', min: 0, max: 100 },
      description: 'Progress percentage (0-100)',
    },
    showDetails: {
      control: 'boolean',
      description: 'Whether to show status details below the progress bar',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes to apply',
    },
  },
} satisfies Meta<typeof ProgressBar>

export default meta
type Story = StoryObj<typeof meta>

export const SimpleProgress: Story = {
  args: {
    progress: 45,
    showDetails: false,
  },
  parameters: {
    docs: {
      description: {
        story: 'A simple progress bar showing upload or general progress.',
      },
    },
  },
}

export const WithDetails: Story = {
  args: {
    progress: 65,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Progress bar with details showing percentage and basic status.',
      },
    },
  },
}

export const Pending: Story = {
  args: {
    transcriptionState: {
      status: 'pending',
      progress: 0,
      message: 'Preparing transcription...',
      jobId: 'job-123',
    } as TranscriptionState,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Progress bar in pending state with transcription context.',
      },
    },
  },
}

export const ExtractingAudio: Story = {
  args: {
    transcriptionState: {
      status: 'extracting_audio',
      progress: 25,
      message: 'Extracting audio from video...',
      jobId: 'job-123',
    } as TranscriptionState,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Progress bar showing audio extraction phase.',
      },
    },
  },
}

export const Transcribing: Story = {
  args: {
    transcriptionState: {
      status: 'transcribing',
      progress: 75,
      message: 'Transcribing speech...',
      jobId: 'job-123',
    } as TranscriptionState,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Progress bar during active transcription with animated dots.',
      },
    },
  },
}

export const Completed: Story = {
  args: {
    transcriptionState: {
      status: 'completed',
      progress: 100,
      message: 'Transcription completed successfully!',
      jobId: 'job-123',
      createdAt: new Date(Date.now() - 120000).toISOString(),
      completedAt: new Date().toISOString(),
    } as TranscriptionState,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Completed progress bar with success state and celebration animation.',
      },
    },
  },
}

export const Failed: Story = {
  args: {
    transcriptionState: {
      status: 'failed',
      progress: 0,
      message: 'Transcription failed. Please try again.',
      error: 'Audio file format not supported',
      jobId: 'job-123',
    } as TranscriptionState,
    showDetails: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Failed progress bar with error message display.',
      },
    },
  },
}

// Animated examples
export const AnimatedProgress: Story = {
  args: {
    transcriptionState: {
      status: 'processing',
      progress: 0,
      message: 'Processing...',
      jobId: 'job-123',
    } as TranscriptionState,
    showDetails: true,
  },
  play: async ({ canvasElement, step }) => {
    const canvas = canvasElement
    // This would typically be handled by the component's animation
    // In a real scenario, you might use Storybook's play function
    // to simulate progress updates
  },
  parameters: {
    docs: {
      description: {
        story: 'Example of animated progress with processing state.',
      },
    },
  },
}