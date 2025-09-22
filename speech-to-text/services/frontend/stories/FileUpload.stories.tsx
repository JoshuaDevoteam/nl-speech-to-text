import type { Meta, StoryObj } from '@storybook/react'
import { fn } from '@storybook/test'
import FileUpload from '@/components/FileUpload'

const onFileSelectAction = fn<(file: File) => void>()

const meta = {
  title: 'Components/FileUpload',
  component: FileUpload,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A drag-and-drop file upload component with support for audio and video files.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    onFileSelect: {
      description: 'Callback function called when a file is selected',
      action: 'fileSelected',
    },
    disabled: {
      control: 'boolean',
      description: 'Whether the upload component is disabled',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes to apply',
    },
  },
  args: {
    onFileSelect: onFileSelectAction,
  },
} satisfies Meta<typeof FileUpload>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    disabled: false,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'The upload component in a disabled state, preventing file selection.',
      },
    },
  },
}

export const WithCustomClassName: Story = {
  args: {
    disabled: false,
    className: 'max-w-md',
  },
  parameters: {
    docs: {
      description: {
        story: 'File upload component with custom styling applied via className.',
      },
    },
  },
}

// Interactive example with file handling
export const Interactive: Story = {
  args: {
    disabled: false,
  },
  render: (args) => (
    <FileUpload
      {...args}
      onFileSelect={(file: File) => {
        console.log('File selected:', {
          name: file.name,
          size: file.size,
          type: file.type,
        })
        alert(`File selected: ${file.name} (${file.type})`)
        args.onFileSelect?.(file)
      }}
    />
  ),
  parameters: {
    docs: {
      description: {
        story: 'Try dragging and dropping a file or clicking to select one. The file details will be logged to the console.',
      },
    },
  },
}
