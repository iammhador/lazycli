import { motion } from "framer-motion";
import {
  ArrowRight,
  Github,
  Settings,
  Zap,
  Terminal,
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

export default function CurrentFeatures({
  containerVariants,
  itemVariants,
  setActiveCommand,
}: {
  containerVariants: import("framer-motion").Variants;
  itemVariants: import("framer-motion").Variants;
  setActiveCommand: (commandId: string) => void;
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
          description:
            "Initialize a new GitHub repository with standard configuration",
        },
        {
          command: "lazy github clone",
          description: "Clone a GitHub repository and set up the project",
        },
        {
          command: "lazy github push",
          description: "Push changes to GitHub with automated commit messages",
        },
        {
          command: "lazy github pull",
          description: "Create pull requests with predefined templates",
        },
      ],
    },
    {
      id: "node-js",
      title: "Node.js Project Setup",
      description:
        "Bootstrap Node.js projects with best practices, TypeScript, and modern configurations",
      icon: Settings,
      color: "from-green-400 via-emerald-500 to-teal-500",
      commands: [
        {
          command: "lazy node-js init",
          description:
            "Initialize a new Node.js project with package.json and basic structure",
        },
      ],
    },
    {
      id: "next-js",
      title: "Next.js Scaffolding",
      description:
        "Generate optimized Next.js applications with TypeScript, Tailwind, and modern tooling",
      icon: Zap,
      color: "from-blue-400 via-cyan-500 to-teal-500",
      commands: [
        {
          command: "lazy next-js init",
          description:
            "Initialize a new Next.js project with TypeScript and Tailwind CSS",
        },
      ],
    },
    {
      id: "vite-js",
      title: "Vite.js Project Setup",
      description:
        "Create lightning-fast Vite.js projects with modern tooling and optimized builds",
      icon: Terminal,
      color: "from-orange-400 via-red-500 to-pink-500",
      commands: [
        {
          command: "lazy vite-js init",
          description:
            "Bootstrap a new Vite project with React, Vue, or Vanilla JS",
        },
      ],
    },
    {
      id: "react-native",
      title: "React Native Development",
      description:
        "Build cross-platform mobile apps with React Native, Expo, and native navigation",
      icon: Smartphone,
      color: "from-indigo-400 via-purple-500 to-pink-500",
      commands: [
        {
          command: "lazy react-native init",
          description: "Initialize React Native app with Expo or CLI setup",
        },
        {
          command: "lazy react-native deps",
          description:
            "Install essential packages and configure state management",
        },
        {
          command: "lazy react-native deploy",
          description: "Configure app store deployment and distribution",
        },
      ],
    },
    {
      id: "django",
      title: "Django Project Setup",
      description:
        "Initialize Python Django projects with virtual environment, project scaffolding, and standard directories",
      icon: Snowflake,
      color: "from-blue-600 via-blue-500 to-cyan-500",
      commands: [
        {
          command: "lazy django init <project_name>",
          description:
            "Create a new Django project with static, templates, media directories, and auto-configured settings",
        },
      ],
    },
  ];

  return (
    <>
      <section id="features" className="py-20">
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
                Powerful Features
              </span>
            </h2>
            <p className="text-xl text-slate-400 max-w-3xl mx-auto">
              Advanced automation tools available right now to supercharge your
              development workflow
            </p>
          </motion.div>

          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
          >
            {currentFeatures.map((feature) => {
              const IconComponent = feature.icon;
              return (
                <motion.div
                  key={feature.id}
                  variants={itemVariants}
                  whileHover={{ y: -10, transition: { duration: 0.2 } }}
                  className="group relative"
                >
                  <div className="bg-slate-800/50 backdrop-blur-xl border border-slate-700 rounded-xl p-6 hover:border-cyan-400/50 transition-all h-full">
                    <div className="relative mb-6">
                      <div
                        className={`w-14 h-14 rounded-xl bg-gradient-to-r ${feature.color} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}
                      >
                        <IconComponent className="w-7 h-7 text-white" />
                      </div>
                      <div
                        className={`absolute inset-0 w-14 h-14 rounded-xl bg-gradient-to-r ${feature.color} blur-lg opacity-0 group-hover:opacity-30 transition-opacity`}
                      />
                    </div>
                    <h3 className="text-xl font-semibold text-white mb-3">
                      {feature.title}
                    </h3>
                    <p className="text-slate-400 mb-6 leading-relaxed">
                      {feature.description}
                    </p>
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => {
                        setActiveCommand(feature.id);
                        const commandsSection =
                          document.getElementById("commands");
                        if (commandsSection) {
                          commandsSection.scrollIntoView({
                            behavior: "smooth",
                            block: "start",
                          });
                        }
                      }}
                      className="text-cyan-400 hover:text-cyan-300 font-medium flex items-center group-hover:translate-x-1 transition-transform"
                    >
                      View Commands
                      <ArrowRight className="w-4 h-4 ml-2" />
                    </motion.button>
                  </div>
                </motion.div>
              );
            })}
          </motion.div>
        </div>
      </section>
    </>
  );
}
