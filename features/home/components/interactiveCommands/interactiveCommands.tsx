import { AnimatePresence, motion } from "framer-motion";
import {
  Settings,
  Terminal,
  Zap,
  Github,
  Command,
  CheckCircle,
  Copy,
  Smartphone,
  Snowflake,
} from "lucide-react";

interface Command {
  command: string;
  description: string;
}

interface Feature {
  id: string;
  title: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  color: string;
  commands: Command[];
}

export default function InteractiveCommands({
  setActiveCommand,
  activeCommand,
  copyToClipboard,
  copiedCommand,
}: {
  setActiveCommand: (commandId: string) => void;
  activeCommand: string;
  copyToClipboard: (text: string) => void;
  copiedCommand: string;
}) {
  // Current features data with Lucide icons
  const currentFeatures: Feature[] = [
    {
      id: "github",
      title: "GitHub Automation",
      description:
        "Streamline your GitHub workflow with automated repository management and CI/CD integration",
      icon: Github,
      color: "from-purple-500 via-pink-500 to-red-500",
      commands: [
        {
          command: "lazy github init",
          description: "Initialize a new Git repository",
        },
        {
          command: "lazy github clone <repo-url>",
          description: "Clone a repo and auto-setup tech stack",
        },
        {
          command: 'lazy github push "<commit-message>"',
          description: "Stage, commit, and push changes",
        },
        {
          command: 'lazy github pull <base-branch> "<pr-title>"',
          description: "Create a simple pull request",
        },
        {
          command: 'lazy github pr <base-branch> "<commit-message>"',
          description: "Full PR workflow",
        },
      ],
    },
    {
      id: "node-js",
      title: "Node.js Project Setup",
      description:
        "Bootstrap Node.js projects with TypeScript, Express, and interactive package selection",
      icon: Settings,
      color: "from-green-400 via-emerald-500 to-teal-500",
      commands: [
        {
          command: "lazy node-js init",
          description:
            "Initialize Node.js project with TypeScript and optional packages",
        },
      ],
    },
    {
      id: "next-js",
      title: "Next.js Scaffolding",
      description:
        "Generate optimized Next.js applications with TypeScript, Tailwind, and optional packages",
      icon: Zap,
      color: "from-blue-400 via-cyan-500 to-teal-500",
      commands: [
        {
          command: "lazy next-js init",
          description:
            "Initialize Next.js app with TypeScript, Tailwind, ESLint, and optional packages",
        },
      ],
    },
    {
      id: "vite-js",
      title: "Vite.js Project Setup",
      description:
        "Create lightning-fast Vite.js projects with framework selection and Tailwind/DaisyUI integration",
      icon: Terminal,
      color: "from-orange-400 via-red-500 to-pink-500",
      commands: [
        {
          command: "lazy vite-js init",
          description:
            "Initialize Vite project with framework selection and optional Tailwind/DaisyUI",
        },
      ],
    },
    {
      id: "react-native",
      title: "React Native Development",
      description:
        "Build cross-platform mobile apps with React Native, Expo/CLI setup, navigation, state management, and UI libraries",
      icon: Smartphone,
      color: "from-indigo-400 via-purple-500 to-pink-500",
      commands: [
        {
          command: "lazy react-native init",
          description:
            "Initialize React Native app with Expo or CLI, including navigation, state management, and UI libraries",
        },
      ],
    },
    {
      id: "django",
      title: "Django Development",
      description:
        "Initialize Django projects with pre-configured structure for static, templates, and media directories",
      icon: Snowflake,
      color: "from-green-500 via-lime-500 to-emerald-500",
      commands: [
        {
          command: "lazy django init <project_name>",
          description:
            "Create Django project with static, templates, and media setup",
        },
      ],
    },
  ];

  return (
    <>
      <section id="commands" className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-3xl md:text-5xl font-bold mb-4">
              <span className="bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
                Commands & Usage
              </span>
            </h2>
            <p className="text-xl text-slate-400 max-w-3xl mx-auto">
              Explore detailed command examples and usage patterns for each
              platform
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="bg-slate-800/50 backdrop-blur-xl border border-slate-700 rounded-2xl overflow-hidden"
          >
            {/* Command Tabs */}
            <div className="flex flex-wrap border-b border-slate-700">
              {currentFeatures.map((feature) => {
                const IconComponent = feature.icon;
                return (
                  <motion.button
                    key={feature.id}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => setActiveCommand(feature.id)}
                    className={`flex-1 min-w-0 py-4 px-3 sm:py-6 sm:px-6 text-center font-medium transition-all ${
                      activeCommand === feature.id
                        ? "text-cyan-400 border-b-2 border-cyan-400 bg-slate-700/50 cursor-pointer"
                        : "text-slate-400 hover:text-white hover:bg-slate-700/30 cursor-pointer"
                    }`}
                  >
                    <div className="flex flex-col items-center">
                      <IconComponent className="w-4 h-4 sm:w-5 sm:h-5 mb-1 sm:mb-2 flex-shrink-0" />
                      <span className="text-xs sm:text-sm leading-tight truncate w-full">
                        {feature.title}
                      </span>
                    </div>
                  </motion.button>
                );
              })}
            </div>

            {/* Command Content */}
            <div className="p-4 sm:p-8">
              <AnimatePresence mode="wait">
                {currentFeatures.map((feature) => (
                  <motion.div
                    key={feature.id}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    transition={{ duration: 0.3 }}
                    className={`${
                      activeCommand === feature.id ? "block" : "hidden"
                    }`}
                  >
                    <div className="mb-6 sm:mb-8">
                      <div className="flex items-start sm:items-center mb-4">
                        <div
                          className={`w-8 h-8 sm:w-10 sm:h-10 rounded-xl bg-gradient-to-r ${feature.color} flex items-center justify-center mr-3 sm:mr-4 flex-shrink-0`}
                        >
                          <feature.icon className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <h3 className="text-xl sm:text-2xl font-bold text-white mb-1 sm:mb-0">
                            {feature.title}
                          </h3>
                          <p className="text-slate-400 text-sm sm:text-base">
                            {feature.description}
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-4 sm:space-y-6">
                      {feature.commands.map((cmd, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: index * 0.1, duration: 0.5 }}
                          whileHover={{ scale: 1.02 }}
                          className="bg-slate-900/50 backdrop-blur-xl border border-slate-700 rounded-xl p-4 sm:p-6 group hover:border-cyan-400/50 transition-all"
                        >
                          <div className="flex items-center justify-between mb-3 sm:mb-4">
                            <span className="text-slate-400 text-xs sm:text-sm flex items-center">
                              <Command className="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2 flex-shrink-0" />
                              Command
                            </span>
                            <motion.button
                              whileHover={{ scale: 1.05 }}
                              whileTap={{ scale: 0.95 }}
                              onClick={() => copyToClipboard(cmd.command)}
                              className="text-cyan-400 hover:text-cyan-300 text-xs sm:text-sm flex items-center px-2 sm:px-3 py-1 bg-cyan-400/10 rounded-lg border border-cyan-400/20 transition-colors flex-shrink-0"
                            >
                              {copiedCommand === cmd.command ? (
                                <>
                                  <CheckCircle className="w-3 h-3 sm:w-4 sm:h-4 mr-1 flex-shrink-0" />
                                  <span className="hidden xs:inline">
                                    Copied!
                                  </span>
                                </>
                              ) : (
                                <>
                                  <Copy className="w-3 h-3 sm:w-4 sm:h-4 mr-1 flex-shrink-0 cursor-pointer" />
                                  <span className="hidden xs:inline">Copy</span>
                                </>
                              )}
                            </motion.button>
                          </div>
                          <code className="text-cyan-400 text-sm sm:text-lg font-mono block mb-3 sm:mb-4 group-hover:text-cyan-300 transition-colors break-all">
                            $ {cmd.command}
                          </code>
                          <p className="text-slate-300 text-xs sm:text-sm leading-relaxed">
                            {cmd.description}
                          </p>
                        </motion.div>
                      ))}
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>
          </motion.div>
        </div>
      </section>
    </>
  );
}
