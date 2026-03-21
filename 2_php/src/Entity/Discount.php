<?php

namespace App\Entity;

use App\Repository\DiscountRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DiscountRepository::class)]
class Discount
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(type: Types::DECIMAL, precision: 10, scale: 5)]
    private ?string $percentage = null;

    #[ORM\Column]
    private ?\DateTime $beginning = null;

    #[ORM\Column]
    private ?\DateTime $ending = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPercentage(): ?string
    {
        return $this->percentage;
    }

    public function setPercentage(string $percentage): static
    {
        $this->percentage = $percentage;

        return $this;
    }

    public function getBeginning(): ?\DateTime
    {
        return $this->beginning;
    }

    public function setBeginning(\DateTime $beginning): static
    {
        $this->beginning = $beginning;

        return $this;
    }

    public function getEnding(): ?\DateTime
    {
        return $this->ending;
    }

    public function setEnding(\DateTime $ending): static
    {
        $this->ending = $ending;

        return $this;
    }
}
