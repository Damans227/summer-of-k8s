### Key Concepts ###

- You don't have to tackle every challenge at once. You can incrementally improve your existing systems. 
  You can start with changes that have the most impact, which are often not the most difficult to implement.
  
- When you decide what you want to modify, remember to optimize for two things: 
  feature velocity and production stability. 
  
- Kubernetes is now a widely used platform on which to run applications. One of its main advantages is that it uses a declarative model. 
  You describe the state that you want your applications to be in, and Kubernetes automatically attempts to reach that state. 
  This declarative model can be contrasted with imperative deployment methods (such as those used by Ansible or Chef) in which
  you describe each step needed to reach the state that you want.
  
- **A deployment artifact, or artifact**, is a packaged application or module that is ready to be deployed and installed. 
  An artifact is immutable: it cannot be modified after it's created. Many different formats for artifacts exist, for example, 
  JAR or WAR files for Java applications, gems for Ruby applications, or Debian or RPM packages. 
  
- In the context of software delivery, the word **deployment** is unfortunately ambiguous. It can mean three things:

    The action of installing and configuring an artifact in a specific environment. For example: "My deployment to production failed."
    The end result of the deployment action. For example: "The staging and production deployments are different."
    A specific Kubernetes object that helps run multiple copies of a container. To distinguish this meaning from the other two, we use a capital D when 
    referring to this Deployment.

    By default, we use the word deployment (with a lowercase d) in the "action" sense.

- **A release** is a specific artifact you deem stable enough to use for production. To create a release, you usually create several artifacts, 
  each new one fixing issues from, or adding features to, the previous one until you reach the stability or feature capabilities you want. 
  Those artifacts can have names such as **alpha, beta, or release candidate**. The concept of release is widely used by software vendors or 
  for software running on end-user devices (mobile apps, desktop software).
  
- **A pipeline** is a computing pattern that takes something as input, runs a series of processing jobs, and returns an output. You can serialize
  or parallelize these stages, and you can represent them by a directed acyclic graph. This article discusses pipelines used in software delivery.
  
- **Continuous integration (CI)** is a methodology in which developers test and build (integrate) their code changes as often as possible. 
  The goal of CI is to tighten the development feedback loop and to surface errors and problems as early as possible in the development process. 
  CI operates on the rationale that the later an error is discovered, the more expensive it is to fix. Discovering a defect in production is, of course, 
  something most developers want to avoid. The usual output of a CI pipeline is an artifact in an artifact storage system.
  
- **Continuous delivery (CD)** is the capability of releasing code at any time. CD assumes that your code has passed the CI pipeline and any tests that you deem 
  necessary (such as smoke testing, QA, and load testing). It's important not to overlook the significant differences between CI and CD. Many organizations 
  create a single pipeline that implements both CI and CD. We do not recommend this setup because CI and CD have the following conflicting goals:

    - *The goal of CI is to provide a short feedback loop to developers.* A CI pipeline should run in less than 10 minutes.
    - *The goal of CD is to ensure the stability of your production environment.* This goal might necessitate processes that can last several 
      hours **(such as canary analysis)**.
      
 - **Continuous delivery and continuous deployment** are often used interchangeably, but in this article we make a distinction. Continuous deployment takes 
   continuous delivery a step further by automatically releasing the application once it passes the required tests.

 - **An environment** is the infrastructure or set of computing, networking, and storage resources on which you deploy your application. When you work in the cloud, 
    instances of managed services are part of the environment. 
    
 - **A configuration** is a piece of information your application needs in order to run that isn't part of the deployment artifact. 
   You can change your configuration without creating or deploying a new artifact.  
   
   
 ### Deployment Model ###
   
 An abstract model is useful in discussions about software delivery and changes to a production system. This section introduces such a conceptual model. 
 Changes you can make to a production system can be organized into five broad categories.
 
 - Deploying a new application version
 - Changing your configuration without changing the deployed artifact
 - Changing a secret that your application uses
 - Changing persistent data
 - Changing the infrastructure

You must treat each of these changes differently. For each category, we provide an overview of related Kubernetes concepts.
