# Contributing to AWS Multi-Environment Infrastructure Template

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Terraform version and AWS provider version
- Relevant error messages/logs

### Suggesting Enhancements

We welcome suggestions for improvements! Please open an issue with:
- Clear description of the enhancement
- Use case/benefit
- Proposed implementation (if applicable)

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test your changes**: Ensure `terraform validate` and `terraform fmt` pass
5. **Update documentation**: If adding features, update relevant docs
6. **Commit your changes**: Use clear, descriptive commit messages
7. **Push to your fork**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**: Provide a clear description of changes

## 📝 Code Style Guidelines

### Terraform

- Use `terraform fmt` to format code
- Follow HashiCorp's Terraform style guide
- Use meaningful variable and resource names
- Add descriptions to all variables and outputs
- Use `for_each` over `count` when possible
- Keep modules focused and single-purpose

### Documentation

- Update README.md if adding features
- Add module-specific READMEs for new modules
- Include examples in documentation
- Keep architecture diagrams updated

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add WAF support for ALB
fix: Correct database subnet group configuration
docs: Update deployment instructions
refactor: Simplify ECS task definition
```

## 🧪 Testing

Before submitting a PR:

1. **Validate Terraform**: `terraform validate`
2. **Format code**: `terraform fmt -recursive`
3. **Check for sensitive data**: Ensure no hardcoded credentials or IDs
4. **Test deployment**: If possible, test in a dev AWS account
5. **Update examples**: Ensure example files are current

## 📋 Pull Request Checklist

- [ ] Code follows style guidelines
- [ ] `terraform fmt` has been run
- [ ] `terraform validate` passes
- [ ] Documentation updated
- [ ] Example files updated (if applicable)
- [ ] No hardcoded values or sensitive data
- [ ] Commit messages are clear

## 🎯 Areas for Contribution

We especially welcome contributions in:

- **Security**: Additional security best practices
- **Cost Optimization**: More cost-saving strategies
- **Monitoring**: Enhanced monitoring and alerting
- **Multi-Region**: Support for multi-region deployments
- **Additional Services**: Support for more AWS services
- **Documentation**: Improvements to guides and examples
- **Testing**: Automated testing and validation

## 📞 Questions?

- Open an issue for questions
- Check existing issues and discussions
- Review the documentation in README.md

Thank you for contributing! 🚀
