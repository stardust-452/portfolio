const USER = "stardust-452";
const REPO = "portfolio";
const BRANCH = "main";


const projects = [

  {
    folder: "DDR",

    title:
      "Sequencing-Based Analysis of Chemotherapy-Induced DNA Damage Response",

    description:
      "Analysis of sequencing data to investigate transcriptional responses to chemotherapy-induced DNA damage."
  },

  {
    folder: "ML",

    title:
      "Machine Learning Projects",

    description:
      "Machine learning and computational projects exploring biological and scientific datasets."
  }

];


async function getGitHub(path) {

  const url =
    `https://api.github.com/repos/${USER}/${REPO}/contents/${path}?ref=${BRANCH}`;

  const response = await fetch(url);

  if (!response.ok) {
    throw new Error("GitHub request failed");
  }

  return response.json();
}


async function getREADME(folder) {

  const url =
    `https://raw.githubusercontent.com/${USER}/${REPO}/${BRANCH}/${folder}/README.md`;

  const response = await fetch(url);

  if (!response.ok) {

    return "# README\n\nNo README found.";

  }

  return response.text();
}


function githubLink(path) {

  return `https://github.com/${USER}/${REPO}/blob/${BRANCH}/${path}`;

}


async function createProject(project, number) {

  const readme =
    await getREADME(project.folder);


  const files =
    await getGitHub(project.folder);


  const card =
    document.createElement("article");

  card.className = "project-card";


  card.innerHTML = `

    <button class="project-header">

      <div>

        <span class="project-number">
          ${String(number).padStart(2, "0")}
        </span>

        <h3>
          ${project.title}
        </h3>

        <p class="project-description">
          ${project.description}
        </p>

      </div>

      <span class="project-toggle">
        +
      </span>

    </button>


    <div class="project-content">

      <div class="project-content-inner">

        <div class="project-readme">

          <h4>README</h4>

          <div class="readme-content">
            ${marked.parse(readme)}
          </div>

        </div>


        <div class="project-files">

          <h4>FILES</h4>

          <div class="file-list">

            ${files.map(file => `

              <a
                class="file-item"
                href="${githubLink(file.path)}"
                target="_blank"
              >

                ${file.type === "dir" ? "📁" : "📄"}
                ${file.name}

              </a>

            `).join("")}

          </div>

        </div>


        <a
          class="github-button"
          href="https://github.com/${USER}/${REPO}/tree/${BRANCH}/${project.folder}"
          target="_blank"
        >
          View project on GitHub →
        </a>

      </div>

    </div>

  `;


  const header =
    card.querySelector(".project-header");


  header.addEventListener("click", () => {

    card.classList.toggle("open");

  });


  return card;

}


async function loadProjects() {

  const container =
    document.getElementById("projects-container");


  container.innerHTML = "";


  for (
    let i = 0;
    i < projects.length;
    i++
  ) {

    try {

      const card =
        await createProject(
          projects[i],
          i + 1
        );

      container.appendChild(card);

    }

    catch (error) {

      console.error(error);

    }

  }

}


loadProjects();

