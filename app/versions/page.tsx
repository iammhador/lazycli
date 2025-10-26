/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";
import React, { useState, useEffect, useRef, Suspense } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useSearchParams } from "next/navigation";
import {
  Download,
  Terminal,
  GitBranch,
  Settings,
  Code,
  Zap,
  Star,
  Clock,
  Package,
  Globe,
  Server,
  Database,
  Cloud,
  Monitor,
  Workflow,
  Rocket,
  Shield,
  Users,
  Calendar,
  Github,
  Command,
  FileText,
  Target,
  Award,
  Activity,
  Hash,
  X,
  ChevronDown,
  CheckCircle,
} from "lucide-react";
import InstallCommandButton from "@/features/versions/components/installCommandButton/InstallCommandButton";
import SuspenseFallback from "@/components/common/suspense-fallback";

// Wrapper component to handle search params with Suspense
function VersionContent() {
  const searchParams = useSearchParams();
  const [activeTab, setActiveTab] = useState("current");
  const [selectedVersion, setSelectedVersion] = useState("v1.0.2");
  const [searchQuery, setSearchQuery] = useState("");
  const [filteredVersions, setFilteredVersions] = useState<any>([]);
  const selectedVersionRef = useRef(null);
  // State for collapsible sections
  const [expandedSections, setExpandedSections] = useState({
    features: true,
    integrations: true,
    commands: true,
  });

  // Handle URL query parameters for version selection
  useEffect(() => {
    const versionParam = searchParams.get("v");
    if (versionParam) {
      const formattedVersion = versionParam.startsWith("v")
        ? versionParam
        : `v${versionParam}`;
      // Check if the version exists in our versions array
      const versionExists = versions.some(
        (v) => v.version === formattedVersion
      );
      if (versionExists) {
        setSelectedVersion(formattedVersion);
        setActiveTab("history");
      }
    }
  }, [searchParams]);

  // Scroll to selected version when it changes
  useEffect(() => {
    if (selectedVersionRef.current) {
      (selectedVersionRef.current as HTMLElement)?.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }
  }, [selectedVersion, activeTab]);

  // Filter versions based on search query
  useEffect(() => {
    if (searchQuery) {
      const filtered = versions.filter(
        (version) =>
          version.version.toLowerCase().includes(searchQuery.toLowerCase()) ||
          version.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          version.features.some(
            (feature) =>
              feature.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
              feature.description
                .toLowerCase()
                .includes(searchQuery.toLowerCase())
          )
      );
      setFilteredVersions(filtered);

      // If we have filtered results and the currently selected version is not in the filtered list,
      // select the first filtered version
      if (
        filtered.length > 0 &&
        !filtered.some((v) => v.version === selectedVersion)
      ) {
        setSelectedVersion(filtered[0].version);
      }
    } else {
      setFilteredVersions(versions);
    }
  }, [searchQuery, selectedVersion]);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 0.6,
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5 },
    },
  };

  const cardVariants = {
    hidden: { opacity: 0, scale: 0.95 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: { duration: 0.4 },
    },
    hover: {
      scale: 1.02,
      transition: { duration: 0.2 },
    },
  };

  const versions = [
    {
      version: "v1.0.4",
      title: "Enhanced Development Workflow",
      date: "2024-01-15",
      status: "current",
      type: "major",
      features: [
        {
          icon: <Package className="w-5 h-5" />,
          title: "Smart Package Manager Detection",
          description:
            "Automatically detects and uses bun, pnpm, yarn, or npm with priority order",
        },
        {
          icon: <Code className="w-5 h-5" />,
          title: "Advanced Node.js Setup",
          description:
            "TypeScript configuration, comprehensive starter templates with Express.js API endpoints",
        },
        {
          icon: <Zap className="w-5 h-5" />,
          title: "Modern Tailwind & DaisyUI",
          description:
            "Updated to use @tailwindcss/vite plugin with framework-specific configurations",
        },
        {
          icon: <Settings className="w-5 h-5" />,
          title: "Improved Next.js Creation",
          description:
            "Fixed interactive prompts with explicit flag handling and --yes option",
        },
      ],
      integrations: [
        {
          name: "GitHub",
          icon: <Github className="w-4 h-4" />,
          status: "enhanced",
        },
        { name: "Vite", icon: <Zap className="w-4 h-4" />, status: "enhanced" },
        {
          name: "Next.js",
          icon: <Code className="w-4 h-4" />,
          status: "enhanced",
        },
        {
          name: "Node.js",
          icon: <Server className="w-4 h-4" />,
          status: "enhanced",
        },
        {
          name: "TypeScript",
          icon: <FileText className="w-4 h-4" />,
          status: "enhanced",
        },
      ],
      commands: [
        'lazy github push "commit message"',
        'lazy github pr main "feature description"',
        "lazy node-js init",
        "lazy next-js init",
        "lazy vite-js init",
      ],
    },
    {
      version: "v1.0.1",
      title: "Simplified Development Suite",
      date: "2023-12-20",
      status: "previous",
      type: "minor",
      features: [
        {
          icon: <Github className="w-5 h-5" />,
          title: "GitHub Workflow Management",
          description:
            "Basic Git operations with repository cloning and push functionality",
        },
        {
          icon: <Package className="w-5 h-5" />,
          title: "Package Manager Detection",
          description:
            "Intelligent detection of bun, pnpm, yarn, or npm for dependency management",
        },
        {
          icon: <Code className="w-5 h-5" />,
          title: "Framework Project Creation",
          description:
            "Simplified Next.js and Vite project scaffolding with TypeScript defaults",
        },
        {
          icon: <Server className="w-5 h-5" />,
          title: "Node.js Project Initialization",
          description:
            "Basic Node.js project setup with package manager compatibility",
        },
      ],
      integrations: [
        { name: "GitHub", icon: <Github className="w-4 h-4" />, status: "new" },
        { name: "Vite", icon: <Zap className="w-4 h-4" />, status: "new" },
        { name: "Next.js", icon: <Code className="w-4 h-4" />, status: "new" },
        {
          name: "Node.js",
          icon: <Server className="w-4 h-4" />,
          status: "new",
        },
      ],
      commands: [
        "lazy github init",
        "lazy github clone <repo-url>",
        'lazy github push "message"',
        'lazy github pr <base> "message"',
        "lazy node-js init",
        "lazy next-js init",
        "lazy vite-js init",
      ],
    },
  ];

  const roadmapItems = [
    {
      version: "v1.1.0",
      title: "Process Management",
      quarter: "Q2 2024",
      status: "planned",
      features: [
        {
          icon: <Activity className="w-5 h-5" />,
          title: "PM2 Integration",
          description: "Advanced process management for Node.js applications",
        },
        {
          icon: <Monitor className="w-5 h-5" />,
          title: "Process Monitoring",
          description: "Real-time application monitoring and health checks",
        },
        {
          icon: <Workflow className="w-5 h-5" />,
          title: "Auto-restart Policies",
          description: "Intelligent application restart and recovery",
        },
      ],
    },
    {
      version: "v1.2.0",
      title: "Cloud Integration",
      quarter: "Q3 2024",
      status: "planned",
      features: [
        {
          icon: <Cloud className="w-5 h-5" />,
          title: "AWS Integration",
          description: "Deploy and manage applications on AWS infrastructure",
        },
        {
          icon: <Database className="w-5 h-5" />,
          title: "Database Management",
          description: "Automated database migrations and backups",
        },
        {
          icon: <Shield className="w-5 h-5" />,
          title: "Security Scanning",
          description: "Automated security vulnerability detection",
        },
      ],
    },
    {
      version: "v1.3.0",
      title: "Enterprise Features",
      quarter: "Q4 2024",
      status: "planned",
      features: [
        {
          icon: <Users className="w-5 h-5" />,
          title: "Team Collaboration",
          description: "Multi-user workflows and team management",
        },
        {
          icon: <Award className="w-5 h-5" />,
          title: "Quality Gates",
          description: "Automated code quality checks and standards",
        },
        {
          icon: <Target className="w-5 h-5" />,
          title: "Custom Pipelines",
          description: "Build custom CI/CD pipelines with visual editor",
        },
      ],
    },
  ];

  const stats = [
    {
      label: "Total Commands",
      value: "10+",
      icon: <Command className="w-6 h-6" />,
    },
    {
      label: "Integrations",
      value: "4",
      icon: <Package className="w-6 h-6" />,
    },
    { label: "Platforms", value: "3", icon: <Globe className="w-6 h-6" /> },
    {
      label: "Active Users",
      value: "250+",
      icon: <Users className="w-6 h-6" />,
    },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case "current":
        return "from-cyan-400 to-blue-400";
      case "new":
        return "from-green-400 to-emerald-400";
      case "enhanced":
        return "from-purple-400 to-pink-400";
      case "planned":
        return "from-yellow-400 to-orange-400";
      default:
        return "from-slate-400 to-slate-500";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "current":
        return "Current Version";
      case "new":
        return "New";
      case "enhanced":
        return "Enhanced";
      case "planned":
        return "Planned";
      default:
        return "Previous";
    }
  };

  // Copy install command with specific version
  const [copiedVersion, setCopiedVersion] = useState<string | null>(null);

  const copyInstallCommand = (version: string) => {
    const versionNumber = version.replace("v", "");
    const command = `curl -s https://lazycli.xyz/install.sh | bash -s install ${versionNumber}`;
    navigator.clipboard.writeText(command);

    // Show visual feedback
    setCopiedVersion(version);
    setTimeout(() => setCopiedVersion(null), 2000);
  };

  const renderVersionDetails = (version: any) => {
    if (!version) return null;

    const toggleSection = (section: string) => {
      setExpandedSections((prev) => ({
        ...prev,
        [section as keyof typeof prev]: !prev[section as keyof typeof prev],
      }));
    };
    return (
      <div
        className="space-y-6"
        ref={version.version === selectedVersion ? selectedVersionRef : null}
      >
        <div className="bg-slate-800/40 backdrop-blur-sm border border-slate-700/50 rounded-2xl p-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <div className="flex items-center space-x-3 mb-2">
                <span
                  className={`px-3 py-1 rounded-full text-sm font-medium text-white bg-gradient-to-r ${getStatusColor(
                    version.status
                  )}`}
                >
                  {version.version}
                </span>
                <span className="text-slate-400">{version.date}</span>
              </div>
              <h3 className="text-2xl font-bold text-white">{version.title}</h3>
            </div>
            <motion.button
              onClick={() => copyInstallCommand(version.version)}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="relative flex items-center space-x-2 px-4 py-2 bg-slate-700/50 hover:bg-cyan-500/20 rounded-lg transition-colors duration-300 overflow-hidden cursor-pointer"
            >
              <AnimatePresence>
                {copiedVersion === version.version && (
                  <motion.div
                    className="absolute inset-0 flex items-center w-full justify-center bg-teal-500/90 backdrop-blur-sm"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.2 }}
                  >
                    <CheckCircle className="w-5 h-5 mr-2 text-white" />
                    <span className="text-white font-medium">Copied!</span>
                  </motion.div>
                )}
              </AnimatePresence>
              <Download className="w-5 h-5 text-cyan-400 cursor-pointer" />
              <span className="text-cyan-400 font-medium">
                Copy Install Command
              </span>
            </motion.button>
          </div>

          <div className="grid md:grid-cols-2 gap-6 mb-8">
            <div>
              <button
                onClick={() => toggleSection("features")}
                className="w-full text-left flex items-center justify-between text-lg font-semibold text-white mb-4"
              >
                <div className="flex items-center cursor-pointer">
                  <Star className="w-5 h-5 mr-2 text-yellow-400 " />
                  Key Features
                </div>
                <ChevronDown
                  className={`w-5 h-5 text-slate-400 transition-transform duration-300 cursor-pointer ${
                    expandedSections.features ? "rotate-180" : ""
                  }`}
                />
              </button>

              <AnimatePresence>
                {expandedSections.features && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="space-y-3 overflow-hidden"
                  >
                    {version.features.map((feature: any, index: number) => (
                      <div key={index} className="flex items-start space-x-3">
                        <div className="text-cyan-400 mt-1">{feature.icon}</div>
                        <div>
                          <h5 className="font-medium text-white">
                            {feature.title}
                          </h5>
                          <p className="text-sm text-slate-400">
                            {feature.description}
                          </p>
                        </div>
                      </div>
                    ))}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>

            <div>
              <button
                onClick={() => toggleSection("integrations")}
                className="w-full text-left flex items-center justify-between text-lg font-semibold text-white mb-4"
              >
                <div className="flex items-center">
                  <GitBranch className="w-5 h-5 mr-2 text-purple-400" />
                  Integrations
                </div>
                <ChevronDown
                  className={`w-5 h-5 text-slate-400 transition-transform duration-300 ${
                    expandedSections.integrations ? "rotate-180" : ""
                  }`}
                />
              </button>

              <AnimatePresence>
                {expandedSections.integrations && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="grid grid-cols-2 gap-3 overflow-hidden"
                  >
                    {version.integrations.map(
                      (integration: any, index: number) => (
                        <div
                          key={index}
                          className="flex items-center justify-between bg-slate-900/40 rounded-lg p-3"
                        >
                          <div className="flex items-center space-x-2">
                            <div className="text-cyan-400">
                              {integration.icon}
                            </div>
                            <span className="text-white font-medium">
                              {integration.name}
                            </span>
                          </div>
                          <span
                            className={`px-2 py-1 rounded text-xs font-medium text-white bg-gradient-to-r ${getStatusColor(
                              integration.status
                            )}`}
                          >
                            {getStatusText(integration.status)}
                          </span>
                        </div>
                      )
                    )}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>

          <div>
            <button
              onClick={() => toggleSection("commands")}
              className="w-full text-left flex items-center justify-between text-lg font-semibold text-white mb-4"
            >
              <div className="flex items-center">
                <Terminal className="w-5 h-5 mr-2 text-green-400" />
                Available Commands
              </div>
              <ChevronDown
                className={`w-5 h-5 text-slate-400 transition-transform duration-300 ${
                  expandedSections.commands ? "rotate-180" : ""
                }`}
              />
            </button>

            <AnimatePresence>
              {expandedSections.commands && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                  className="bg-slate-900/60 rounded-xl p-4 border border-slate-700/50 overflow-hidden"
                >
                  <div className="space-y-2">
                    {version.commands.map((command: string, index: number) => (
                      <div key={index} className="flex items-center space-x-2">
                        <Hash className="w-4 h-4 text-cyan-400" />
                        <code className="text-cyan-300 font-mono">
                          {command}
                        </code>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0">
        <motion.div
          className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-r from-cyan-400/10 to-blue-400/10 rounded-full blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, -50, 0],
            scale: [1, 1.1, 1],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            repeatType: "reverse",
          }}
        />
        <motion.div
          className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-to-l from-purple-400/10 to-pink-400/10 rounded-full blur-3xl"
          animate={{
            x: [0, -100, 0],
            y: [0, 50, 0],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 25,
            repeat: Infinity,
            repeatType: "reverse",
          }}
        />
      </div>

      <motion.div
        className="relative z-10 mx-auto px-6 pt-24 pb-16"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* Header */}
        <motion.div variants={itemVariants} className="text-center mb-16">
          <motion.div
            className="flex justify-center mb-6"
            whileHover={{ scale: 1.05 }}
            transition={{ duration: 0.3 }}
          >
            <div className="bg-gradient-to-r from-cyan-400/20 to-blue-400/20 p-6 rounded-2xl backdrop-blur-sm border border-cyan-500/20">
              <Terminal className="w-16 h-16 text-cyan-500" />
            </div>
          </motion.div>

          <motion.h1
            className="text-6xl font-bold mb-6 bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            LazyCLI – Dev Automation, Your Way
          </motion.h1>

          <motion.p
            className="text-xl text-slate-400 max-w-3xl mx-auto leading-relaxed"
            variants={itemVariants}
          >
            A cross-platform, customizable CLI toolkit that helps you automate
            Git, Node.js, PM2, Vite, Next.js, AWS workflows and more — tailored
            to your personal dev setup.
          </motion.p>
        </motion.div>

        {/* Stats */}
        <motion.div
          className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-16"
          variants={itemVariants}
        >
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              className="bg-slate-800/40 backdrop-blur-sm border border-slate-700/50 rounded-2xl p-6 text-center"
              whileHover={{ scale: 1.05 }}
            >
              <div className="flex justify-center mb-3">
                <div className="text-cyan-400">{stat.icon}</div>
              </div>
              <div className="text-3xl font-bold text-white mb-1">
                {stat.value}
              </div>
              <div className="text-slate-400 text-sm">{stat.label}</div>
            </motion.div>
          ))}
        </motion.div>

        {/* Navigation Tabs */}
        <motion.div
          className="flex justify-center mb-12"
          variants={itemVariants}
        >
          <div className="bg-slate-800/50 backdrop-blur-sm p-2 rounded-2xl border border-slate-700/50">
            <div className="flex space-x-2">
              {[
                {
                  id: "current",
                  label: "Current Version",
                  icon: <Star className="w-5 h-5" />,
                },
                {
                  id: "history",
                  label: "Version History",
                  icon: <Clock className="w-5 h-5" />,
                },
                {
                  id: "roadmap",
                  label: "Roadmap",
                  icon: <Rocket className="w-5 h-5" />,
                },
              ].map((tab) => (
                <motion.button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-2 px-8 py-4 rounded-xl font-medium transition-all duration-300 ${
                    activeTab === tab.id
                      ? "bg-gradient-to-r from-cyan-400 to-blue-400 text-white shadow-lg shadow-cyan-400/25 cursor-pointer"
                      : "text-slate-400 hover:text-white hover:bg-slate-700/50 cursor-pointer"
                  }`}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  {tab.icon}
                  <span>{tab.label}</span>
                </motion.button>
              ))}
            </div>
          </div>
        </motion.div>

        {/* Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial="hidden"
            animate="visible"
            exit="hidden"
            variants={containerVariants}
            className="max-w-6xl mx-auto"
          >
            {activeTab === "current" && renderVersionDetails(versions[0])}

            {activeTab === "history" && (
              <div className="space-y-8 ">
                {/* Search and filter */}
                <div className="flex flex-col items-center mb-8 space-y-4">
                  <div className="w-full max-w-md">
                    <div className="relative">
                      <input
                        type="text"
                        placeholder="Search by version or title..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full bg-slate-800/50 border border-slate-700/50 rounded-xl px-4 py-3 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-cyan-400/50"
                      />
                      {searchQuery && (
                        <button
                          onClick={() => setSearchQuery("")}
                          className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-white cursor-pointer"
                        >
                          <X className="w-5 h-5" />
                        </button>
                      )}
                    </div>
                  </div>

                  <div className="bg-slate-800/50 backdrop-blur-sm p-2 rounded-xl border border-slate-700/50 w-full max-w-4xl overflow-x-auto">
                    <div className="flex space-x-2 min-w-max">
                      {filteredVersions.length > 0 ? (
                        filteredVersions.map((version: any) => (
                          <motion.button
                            key={version.version}
                            onClick={() => setSelectedVersion(version.version)}
                            className={`px-6 py-3 rounded-lg font-medium transition-all duration-300 ${
                              selectedVersion === version.version
                                ? "bg-gradient-to-r from-cyan-400 to-blue-400 text-white"
                                : "text-slate-400 hover:text-white hover:bg-slate-700/50"
                            }`}
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                          >
                            {version.version}
                          </motion.button>
                        ))
                      ) : (
                        <div className="px-6 py-3 text-slate-400">
                          No versions found
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {filteredVersions.length > 0 &&
                  renderVersionDetails(
                    filteredVersions.find(
                      (v: any) => v.version === selectedVersion
                    ) || filteredVersions[0]
                  )}
              </div>
            )}

            {activeTab === "roadmap" && (
              <div className="space-y-8">
                <div className="text-center mb-12">
                  <h2 className="text-3xl font-bold text-white mb-4">
                    Development Roadmap
                  </h2>
                  <p className="text-slate-400 text-lg">
                    Upcoming features and integrations planned for future
                    releases
                  </p>
                </div>

                <div className="space-y-8">
                  {roadmapItems.map((item, index) => (
                    <motion.div
                      key={index}
                      variants={cardVariants}
                      whileHover="hover"
                      className="bg-slate-800/40 backdrop-blur-sm border border-slate-700/50 rounded-2xl p-8"
                    >
                      <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center space-x-3">
                          <span
                            className={`px-3 py-1 rounded-full text-sm font-medium text-white bg-gradient-to-r ${getStatusColor(
                              item.status
                            )}`}
                          >
                            {item.version}
                          </span>
                          <h3 className="text-2xl font-bold text-white">
                            {item.title}
                          </h3>
                        </div>
                        <div className="flex items-center space-x-2 text-slate-400">
                          <Calendar className="w-4 h-4" />
                          <span>{item.quarter}</span>
                        </div>
                      </div>

                      <div className="grid md:grid-cols-3 gap-6">
                        {item.features.map(
                          (feature: any, featureIndex: number) => (
                            <div
                              key={featureIndex}
                              className="bg-slate-900/40 rounded-xl p-4"
                            >
                              <div className="flex items-center space-x-3 mb-3">
                                <div className="text-cyan-400">
                                  {feature.icon}
                                </div>
                                <h4 className="font-semibold text-white">
                                  {feature.title}
                                </h4>
                              </div>
                              <p className="text-sm text-slate-400">
                                {feature.description}
                              </p>
                            </div>
                          )
                        )}
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            )}
          </motion.div>
        </AnimatePresence>

        {/* Download CTA */}
        <InstallCommandButton />
      </motion.div>
    </div>
  );
}

// Main component with Suspense boundary
export default function VersionDetailsPage() {
  return (
    <Suspense
      fallback={
        <SuspenseFallback message="Loading version details..." size="large" />
      }
    >
      <VersionContent />
    </Suspense>
  );
}
