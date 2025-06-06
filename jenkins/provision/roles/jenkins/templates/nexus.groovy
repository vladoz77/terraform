import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.domains.Domain
import jenkins.model.Jenkins

def username = "jenkins"
def password = "jenkins"
def description = "Token for Nexus repo"
def id = "nexus-token"

def credentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    id,
    description,
    username,
    password
)

def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

store.addCredentials(domain, credentials)

println("✅ Логин/пароль добавлен как credential с ID: $id")